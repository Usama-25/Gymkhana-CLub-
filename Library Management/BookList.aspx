<%@ page language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" autoeventwireup="true"
    CodeFile="BookList.aspx.cs" Inherits="Pages_Books_BookList" title="Book Catalogue - Lahore Gymkhana Library" %>

    <asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
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
                text-align: left;
            }

            .autocomplete-suggestions div:hover {
                background-color: #f1f5f9;
                color: #0f1e36;
            }

            .autocomplete-suggestions div:active {
                background-color: #e2e8f0;
            }
        </style>
    </asp:Content>

    <asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">

        <!-- Header -->
        <div
            style="background: linear-gradient(135deg, #0f1e36, #1c3254); color: #ffffff; padding: 20px 28px; border-radius: 8px; margin-bottom: 24px; border-bottom: 3px solid #c5a059; display: flex; justify-content: space-between; align-items: center; width: 100%; box-sizing: border-box;">
            <div style="display: block;">
                <h2 style="margin: 0; font-size: 22px; font-weight: 600;">Book Catalogue</h2>
                <p style="margin: 4px 0 0; opacity: .8; font-size: 13px;">Lahore Gymkhana Club - Comprehensive catalogue
                    management</p>
            </div>
            <a href="AddEditBook.aspx"
                style="display: inline-flex; align-items: center; justify-content: center; padding: 9px 18px; border-radius: 8px; border: none; cursor: pointer; font-size: 13.5px; font-weight: 600; text-decoration: none; background: #c5a059; color: #0f1e36; box-shadow: 0 4px 12px rgba(197, 160, 89, 0.25);">
                Add New Book
            </a>
        </div>

        <!-- Dynamic alert messages -->
        <asp:Panel ID="pnlSuccess" runat="server" Visible="false" style="width: 100%;">
            <div
                style="padding: 12px 20px; border-radius: 8px; font-size: 14px; margin-bottom: 20px; border-left: 4px solid #10b981; background: #d1fae5; color: #065f46; width: 100%; box-sizing: border-box;">
                <asp:Literal ID="litSuccessMsg" runat="server" />
            </div>
        </asp:Panel>

        <!-- Advanced Filter Panel -->
        <div
            style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px; margin-bottom: 24px; box-shadow: 0 1px 2px 0 rgba(0,0,0,0.05); width: 100%; box-sizing: border-box;">
            <div
                style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; align-items: flex-end; width: 100%;">
                <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                    <label
                        style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin: 0;">Search
                        Keyword</label>
                    <asp:TextBox ID="txtSearch" runat="server"
                        style="width: 100%; padding: 9px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box;"
                        placeholder="Title, ISBN, author, tags..." />
                </div>
                <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                    <label
                        style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin: 0;">Book No.</label>
                    <asp:TextBox ID="txtBookNo" runat="server" placeholder="Search Book No..."
                        style="width: 100%; padding: 9px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 40px;" />
                </div>
                <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                    <label
                        style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin: 0;">Subject</label>
                    <asp:DropDownList ID="ddlCategory" runat="server"
                        style="width: 100%; padding: 9px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 40px;" />
                </div>
                <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                    <label
                        style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin: 0;">Language</label>
                    <asp:DropDownList ID="ddlLanguage" runat="server"
                        style="width: 100%; padding: 9px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 40px;" />
                </div>
                <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                    <label
                        style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin: 0;">Publisher</label>
                    <div style="position: relative; width: 100%;">
                        <asp:TextBox ID="txtPublisher" runat="server" placeholder="Type publisher name..."
                            autocomplete="off"
                            style="width: 100%; padding: 9px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 40px;" />
                        <div id="publisherSuggestions" class="autocomplete-suggestions"
                            style="display: none; position: absolute; top: 100%; left: 0; right: 0; background: white; border: 1px solid #cbd5e1; border-radius: 6px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); z-index: 1000; max-height: 200px; overflow-y: auto; margin-top: 4px;">
                        </div>
                    </div>
                </div>
                <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                    <label
                        style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin: 0;">DDC
                        Call Number</label>
                    <asp:TextBox ID="txtDDC" runat="server" placeholder="Search DDC..."
                        style="width: 100%; padding: 9px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 40px;" />
                </div>
                <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                    <div
                        style="display: flex; align-items: center; gap: 8px; padding: 10px 0; cursor: pointer; width: 100%;">
                        <asp:CheckBox ID="chkAvailOnly" runat="server"
                            style="width: 18px; height: 18px; accent-color: #c5a059; cursor: pointer;" />
                        <span style="font-size: 13px; font-weight: 600; color: #1e293b;">Show Available Only</span>
                    </div>
                </div>
                <div
                    style="display: flex; flex-direction: column; gap: 6px; min-width: 150px; width: 100%; box-sizing: border-box;">
                    <asp:Button ID="btnSearch" runat="server" Text="Filter"
                        style="width: 100%; padding: 9px 18px; border-radius: 8px; border: none; cursor: pointer; font-size: 13.5px; font-weight: 600; background: #0f1e36; color: #ffffff;"
                        OnClick="btnSearch_Click" />
                </div>
            </div>
        </div>

        <!-- Book Results Single-Line Table -->
        <div style="display: flex; flex-direction: column; width: 100%; box-sizing: border-box;">
            
            <asp:Panel ID="pnlResultsTable" runat="server" style="width: 100%;">
                <div style="width: 100%; overflow-x: auto; background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 1px 3px 0 rgba(0,0,0,0.05); margin-bottom: 24px;">
                    <table class="search-results-table" style="width: 100%; border-collapse: collapse; text-transform: uppercase; font-size: 13px;">
                        <thead>
                            <tr style="background: #0f1e36; color: #ffffff; text-align: left; font-size: 11px; font-weight: 700; letter-spacing: 0.5px;">
                                <th style="padding: 14px 16px; border-bottom: 2px solid #c5a059;">BOOK NO.</th>
                                <th style="padding: 14px 16px; border-bottom: 2px solid #c5a059;">TITLE</th>
                                <th style="padding: 14px 16px; border-bottom: 2px solid #c5a059;">AUTHOR</th>
                                <th style="padding: 14px 16px; border-bottom: 2px solid #c5a059;">DDC NUMBER</th>
                                <th style="padding: 14px 16px; border-bottom: 2px solid #c5a059;">CATEGORY</th>
                                <th style="padding: 14px 16px; border-bottom: 2px solid #c5a059;">STATUS</th>
                                <th style="padding: 14px 16px; border-bottom: 2px solid #c5a059; text-align: right;">ACTION</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptBooks" runat="server" OnItemCommand="rptBooks_ItemCommand">
                                <ItemTemplate>
                                    <tr style="border-bottom: 1px solid #e2e8f0; transition: background-color 0.15s ease;" onmouseover="this.style.backgroundColor='#f8fafc'" onmouseout="this.style.backgroundColor='transparent'">
                                        <td style="padding: 12px 16px; font-weight: 700; color: #0f1e36; white-space: nowrap;">
                                            <%# GetBookNoDisplay(Eval("BookNo"), Eval("BookID")) %>
                                        </td>
                                        <td style="padding: 12px 16px; font-weight: 700;">
                                            <a href="javascript:void(0);" onclick="openBookModal(<%# Eval("BookID") %>)" style="color: #0f1e36; text-decoration: underline; cursor: pointer;">
                                                <%# Eval("Title") %>
                                            </a>
                                        </td>
                                        <td style="padding: 12px 16px; color: #334155; font-weight: 500;">
                                            <%# Eval("Authors") %>
                                        </td>
                                        <td style="padding: 12px 16px; color: #475569; font-weight: 600; white-space: nowrap;">
                                            <%# (Eval("DDC") == DBNull.Value || string.IsNullOrEmpty(Eval("DDC").ToString())) ? "-" : Eval("DDC").ToString().Replace("\r","").Replace("\n"," / ") %>
                                        </td>
                                        <td style="padding: 12px 16px; color: #475569; font-weight: 600;">
                                            <%# Eval("CatName") %>
                                        </td>
                                        <td style="padding: 12px 16px; white-space: nowrap;">
                                            <%# FormatStatusBadge(Eval("IsReference"), Eval("IsAdults"), Eval("IsChildren"), Eval("AvailableCopies")) %>
                                        </td>
                                        <td style="padding: 12px 16px; text-align: right; white-space: nowrap;">
                                            <a href="javascript:void(0);" onclick="openBookModal(<%# Eval("BookID") %>)" style="display: inline-flex; align-items: center; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 700; border: 1px solid #c5a059; color: #0f1e36; text-decoration: none; background: #fff8eb; margin-right: 4px;">VIEW DETAILS</a>
                                            <a href='AddEditBook.aspx?BookID=<%# Eval("BookID") %>' style="display: inline-flex; align-items: center; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 600; border: 1px solid #cbd5e1; color: #1e293b; text-decoration: none; background: #ffffff; margin-right: 4px;">EDIT</a>
                                            <asp:LinkButton ID="btnDirectIssue" runat="server" CommandName="Issue" CommandArgument='<%# Eval("BookID") %>' Visible='<%# Convert.ToInt32(Eval("AvailableCopies")) > 0 %>' style="display: inline-flex; align-items: center; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 700; border: none; background: #0f1e36; color: #ffffff; text-decoration: none;">ISSUE</asp:LinkButton>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </asp:Panel>

            <!-- Pagination Pager -->
            <asp:Panel ID="pnlPager" runat="server"
                style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-top: 16px; margin-bottom: 16px; width: 100%; box-sizing: border-box;">
                <asp:HyperLink ID="lnkPrev" runat="server"
                    style="padding: 8px 16px; border-radius: 8px; border: 1px solid #cbd5e1; background: #ffffff; color: #0f1e36; text-decoration: none; font-size: 13px; font-weight: 600; display: inline-flex; align-items: center; transition: all 0.25s ease;"
                    Text="&laquo; Previous" />

                <asp:Repeater ID="rptPager" runat="server">
                    <ItemTemplate>
                        <asp:HyperLink runat="server" NavigateUrl='<%# Eval("Url") %>'
                            style='<%# Convert.ToBoolean(Eval("IsActive")) ? "padding: 8px 14px; border-radius: 8px; border: 1px solid #c5a059; background: #c5a059; color: #0f1e36; font-weight: 700; text-decoration: none; font-size: 13px;" : "padding: 8px 14px; border-radius: 8px; border: 1px solid #cbd5e1; background: #ffffff; color: #0f1e36; text-decoration: none; font-size: 13px; transition: all 0.25s ease;" %>'
                            Text='<%# Eval("Text") %>' />
                    </ItemTemplate>
                </asp:Repeater>

                <asp:HyperLink ID="lnkNext" runat="server"
                    style="padding: 8px 16px; border-radius: 8px; border: 1px solid #cbd5e1; background: #ffffff; color: #0f1e36; text-decoration: none; font-size: 13px; font-weight: 600; display: inline-flex; align-items: center; transition: all 0.25s ease;"
                    Text="Next &raquo;" />
            </asp:Panel>

            <!-- Empty State when no records are returned -->
            <asp:Panel ID="pnlEmptyState" runat="server" Visible="false" style="width: 100%;">
                <div
                    style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 48px; text-align: center; max-width: 600px; margin: 40px auto; box-shadow: 0 1px 2px 0 rgba(0,0,0,0.05); display: flex; flex-direction: column; align-items: center; justify-content: center; box-sizing: border-box;">
                    <h3 style="font-size: 18px; font-weight: 700; color: #0f1e36; margin-bottom: 6px; margin-top: 0;">NO BOOKS FOUND</h3>
                    <p style="font-size: 13.5px; color: #64748b; margin-bottom: 20px;">WE COULD NOT FIND ANY BOOKS MATCHING YOUR SEARCH FILTERS. TRY ADJUSTING YOUR KEYWORDS OR CATEGORIES.</p>
                    <asp:LinkButton ID="btnClearFilters" runat="server"
                        style="display: inline-flex; align-items: center; padding: 9px 18px; border-radius: 8px; border: 1px solid #cbd5e1; color: #1e293b; text-decoration: none; background: #ffffff;"
                        OnClick="btnClearFilters_Click">CLEAR SEARCH FILTERS</asp:LinkButton>
                </div>
            </asp:Panel>
        </div>

        <!-- Bibliographic Record Modal -->
        <div id="mdlBookDetail" style="display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(15, 30, 54, 0.75); backdrop-filter: blur(4px); z-index: 9999; justify-content: center; align-items: center; padding: 20px; box-sizing: border-box;">
            <div style="background: #ffffff; border-radius: 12px; max-width: 850px; width: 100%; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.2), 0 10px 10px -5px rgba(0,0,0,0.04); overflow: hidden; border: 1px solid #cbd5e1; text-transform: uppercase; display: flex; flex-direction: column; max-height: 90vh;">
                <div style="background: linear-gradient(135deg, #0f1e36, #1c3254); color: #ffffff; padding: 16px 24px; display: flex; justify-content: space-between; align-items: center; border-bottom: 3px solid #c5a059;">
                    <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: #ffffff;" id="lblModalHeader">COMPLETE BIBLIOGRAPHIC RECORD</h3>
                    <button type="button" onclick="closeBookModal()" style="background: none; border: none; color: #ffffff; font-size: 24px; cursor: pointer; line-height: 1;">&times;</button>
                </div>
                <div style="padding: 24px; overflow-y: auto; flex: 1;">
                    <div style="display: flex; gap: 24px; flex-wrap: wrap;">
                        <!-- Cover Image Column -->
                        <div style="flex: 0 0 160px; text-align: center;">
                            <div id="modalCoverContainer" style="width: 160px; height: 220px; border-radius: 8px; border: 1px solid #cbd5e1; background: #f8fafc; display: flex; align-items: center; justify-content: center; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);">
                                <img id="modalCoverImg" src="" alt="Book Cover" style="width: 100%; height: 100%; object-fit: cover; display: none;" />
                                <div id="modalCoverPlaceholder" style="color: #64748b; font-size: 11px; font-weight: 700; padding: 12px; text-align: center;">NO COVER PICTURE AVAILABLE</div>
                            </div>
                        </div>
                        <!-- Bibliographic Record Main Column -->
                        <div style="flex: 1; min-width: 280px;">
                            <h2 id="modalTitle" style="margin: 0 0 4px; font-size: 20px; font-weight: 700; color: #0f1e36;"></h2>
                            <div id="modalSubTitle" style="font-size: 13px; color: #64748b; font-style: italic; margin-bottom: 12px; display: none;"></div>
                            <div style="font-size: 14px; font-weight: 600; color: #1e293b; margin-bottom: 16px; padding-bottom: 8px; border-bottom: 1px solid #e2e8f0;">
                                BY: <span id="modalAuthors" style="color: #0f1e36;"></span>
                            </div>

                            <!-- Metadata Grid -->
                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 10px; background: #f8fafc; padding: 16px; border-radius: 8px; border: 1px solid #e2e8f0; font-size: 12px;">
                                <div><span style="color: #64748b; font-weight: 600;">BOOK NO:</span> <strong id="modalBookNo" style="color: #0f1e36;"></strong></div>
                                <div><span style="color: #64748b; font-weight: 600;">DDC CALL NO:</span> <strong id="modalDDC" style="color: #0f1e36;"></strong></div>
                                <div><span style="color: #64748b; font-weight: 600;">SUBJECT / CAT:</span> <strong id="modalCatName" style="color: #0f1e36;"></strong></div>
                                <div><span style="color: #64748b; font-weight: 600;">LANGUAGE:</span> <strong id="modalLangName" style="color: #0f1e36;"></strong></div>
                                <div><span style="color: #64748b; font-weight: 600;">PUBLISHER:</span> <strong id="modalPubName" style="color: #0f1e36;"></strong></div>
                                <div><span style="color: #64748b; font-weight: 600;">PUBLISH YEAR:</span> <strong id="modalPubYear" style="color: #0f1e36;"></strong></div>
                                <div><span style="color: #64748b; font-weight: 600;">ISBN-13:</span> <strong id="modalISBN13" style="color: #0f1e36;"></strong></div>
                                <div><span style="color: #64748b; font-weight: 600;">ISBN-10:</span> <strong id="modalISBN10" style="color: #0f1e36;"></strong></div>
                                <div><span style="color: #64748b; font-weight: 600;">EDITION:</span> <strong id="modalEdition" style="color: #0f1e36;"></strong></div>
                                <div><span style="color: #64748b; font-weight: 600;">PAGES:</span> <strong id="modalPageCount" style="color: #0f1e36;"></strong></div>
                                <div><span style="color: #64748b; font-weight: 600;">BOOK TYPE:</span> <strong id="modalBookType" style="color: #0f1e36;"></strong></div>
                                <div><span style="color: #64748b; font-weight: 600;">AUDIENCE:</span> <strong id="modalAudience" style="color: #0f1e36;"></strong></div>
                                <div><span style="color: #64748b; font-weight: 600;">TOTAL COPIES:</span> <strong id="modalTotalCopies" style="color: #0f1e36;"></strong></div>
                                <div><span style="color: #64748b; font-weight: 600;">AVAILABLE COPIES:</span> <strong id="modalAvailableCopies" style="color: #0f1e36;"></strong></div>
                            </div>

                            <!-- Synopsis -->
                            <div id="modalSynopsisBox" style="margin-top: 14px; font-size: 12px; display: none;">
                                <span style="color: #64748b; font-weight: 700; display: block; margin-bottom: 2px;">SYNOPSIS / DESCRIPTION:</span>
                                <div id="modalSynopsis" style="color: #334155; line-height: 1.5; background: #ffffff; padding: 10px; border-radius: 6px; border: 1px solid #cbd5e1;"></div>
                            </div>

                            <!-- Physical Copies List -->
                            <div style="margin-top: 18px;">
                                <h4 style="margin: 0 0 8px; font-size: 13px; font-weight: 700; color: #0f1e36; border-bottom: 2px solid #c5a059; padding-bottom: 4px;">PHYSICAL COPIES RESULTS</h4>
                                <div id="modalCopiesTable" style="font-size: 12px;"></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div style="background: #f8fafc; padding: 12px 24px; display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid #e2e8f0;">
                    <a id="modalEditLink" href="#" style="display: inline-flex; align-items: center; padding: 8px 16px; border-radius: 6px; border: 1px solid #cbd5e1; color: #1e293b; font-weight: 600; font-size: 12px; text-decoration: none; background: #ffffff;">EDIT CATALOGUE RECORD</a>
                    <button type="button" onclick="closeBookModal()" style="padding: 8px 18px; border-radius: 6px; border: none; background: #0f1e36; color: #ffffff; font-weight: 700; font-size: 12px; cursor: pointer;">CLOSE</button>
                </div>
            </div>
        </div>

        <script>
            function callWebMethod(method, data, onSuccess) {
                fetch('BookList.aspx/' + method, {
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

            function openBookModal(bookID) {
                var modal = document.getElementById('mdlBookDetail');
                if (!modal) return;

                document.getElementById('modalTitle').innerText = 'LOADING RECORD...';
                document.getElementById('modalSubTitle').style.display = 'none';
                document.getElementById('modalAuthors').innerText = '-';
                document.getElementById('modalBookNo').innerText = '-';
                document.getElementById('modalDDC').innerText = '-';
                document.getElementById('modalCatName').innerText = '-';
                document.getElementById('modalLangName').innerText = '-';
                document.getElementById('modalPubName').innerText = '-';
                document.getElementById('modalPubYear').innerText = '-';
                document.getElementById('modalISBN13').innerText = '-';
                document.getElementById('modalISBN10').innerText = '-';
                document.getElementById('modalEdition').innerText = '-';
                document.getElementById('modalPageCount').innerText = '-';
                document.getElementById('modalBookType').innerText = '-';
                document.getElementById('modalAudience').innerText = '-';
                document.getElementById('modalTotalCopies').innerText = '-';
                document.getElementById('modalAvailableCopies').innerText = '-';
                document.getElementById('modalSynopsisBox').style.display = 'none';
                document.getElementById('modalCoverImg').style.display = 'none';
                document.getElementById('modalCoverPlaceholder').style.display = 'block';
                document.getElementById('modalCopiesTable').innerHTML = '<div style="padding: 10px; color: #64748b;">LOADING PHYSICAL COPIES...</div>';

                modal.style.display = 'flex';

                callWebMethod('GetBookFullDetail', { bookID: bookID }, function (res) {
                    if (!res) {
                        alert('ERROR: COULD NOT LOAD BOOK DETAILS.');
                        closeBookModal();
                        return;
                    }

                    document.getElementById('modalTitle').innerText = (res.Title || '').toUpperCase();
                    if (res.SubTitle && res.SubTitle.trim() !== '') {
                        var sub = document.getElementById('modalSubTitle');
                        sub.innerText = res.SubTitle.toUpperCase();
                        sub.style.display = 'block';
                    }

                    document.getElementById('modalAuthors').innerText = (res.Authors || 'UNKNOWN').toUpperCase();
                    document.getElementById('modalBookNo').innerText = (res.BookNo || '-').toUpperCase();
                    document.getElementById('modalDDC').innerText = (res.DDC || '-').toUpperCase();
                    document.getElementById('modalCatName').innerText = (res.CatName || '-').toUpperCase();
                    document.getElementById('modalLangName').innerText = (res.LangName || '-').toUpperCase();
                    document.getElementById('modalPubName').innerText = (res.PubName || '-').toUpperCase();
                    document.getElementById('modalPubYear').innerText = (res.PublishYear || '-').toUpperCase();
                    document.getElementById('modalISBN13').innerText = (res.ISBN13Fmt || '-').toUpperCase();
                    document.getElementById('modalISBN10').innerText = (res.ISBN10 || '-').toUpperCase();
                    document.getElementById('modalEdition').innerText = (res.Edition || '-').toUpperCase();
                    document.getElementById('modalPageCount').innerText = (res.PageCount || '-').toUpperCase();
                    document.getElementById('modalBookType').innerText = (res.BookType || '-').toUpperCase();
                    document.getElementById('modalAudience').innerText = (res.Audience || '-').toUpperCase();
                    document.getElementById('modalTotalCopies').innerText = (res.TotalCopies || '0').toUpperCase();
                    document.getElementById('modalAvailableCopies').innerText = (res.AvailableCopies || '0').toUpperCase();

                    if (res.Synopsis && res.Synopsis.trim() !== '') {
                        document.getElementById('modalSynopsis').innerText = res.Synopsis.toUpperCase();
                        document.getElementById('modalSynopsisBox').style.display = 'block';
                    }

                    var coverSrc = res.CoverUrl || (res.CoverFile ? ('../Images/BookCovers/' + res.CoverFile) : '');
                    if (coverSrc && coverSrc.trim() !== '') {
                        var img = document.getElementById('modalCoverImg');
                        img.src = coverSrc;
                        img.onload = function() {
                            img.style.display = 'block';
                            document.getElementById('modalCoverPlaceholder').style.display = 'none';
                        };
                        img.onerror = function() {
                            if (img.src.indexOf('BookCovers/') === -1) {
                                img.src = '../Images/BookCovers/' + res.CoverFile;
                            } else {
                                img.style.display = 'none';
                                document.getElementById('modalCoverPlaceholder').style.display = 'block';
                            }
                        };
                    }

                    document.getElementById('modalEditLink').href = 'AddEditBook.aspx?BookID=' + res.BookID;

                    var copiesHtml = '';
                    if (res.Copies && res.Copies.length > 0) {
                        copiesHtml += '<table style="width: 100%; border-collapse: collapse; text-transform: uppercase; margin-top: 6px;">';
                        copiesHtml += '<thead><tr style="background: #f1f5f9; text-align: left; color: #475569; font-weight: 700; font-size: 11px;">';
                        copiesHtml += '<th style="padding: 8px; border: 1px solid #e2e8f0;">BARCODE / COPY ID</th>';
                        copiesHtml += '<th style="padding: 8px; border: 1px solid #e2e8f0;">BOOK NO.</th>';
                        copiesHtml += '<th style="padding: 8px; border: 1px solid #e2e8f0;">CONDITION</th>';
                        copiesHtml += '<th style="padding: 8px; border: 1px solid #e2e8f0;">STATUS</th>';
                        copiesHtml += '<th style="padding: 8px; border: 1px solid #e2e8f0;">SHELF LOCATION</th>';
                        copiesHtml += '</tr></thead><tbody>';

                        res.Copies.forEach(function (cp) {
                            var statusBadge = cp.IsAvailable 
                                ? '<span style="color: #16a34a; font-weight: 700;">AVAILABLE</span>' 
                                : '<span style="color: #ef4444; font-weight: 700;">CHECKED OUT</span>';
                            
                            copiesHtml += '<tr>';
                            copiesHtml += '<td style="padding: 8px; border: 1px solid #e2e8f0; font-weight: 700; color: #0f1e36;">' + (cp.Barcode || '-').toUpperCase() + '</td>';
                            copiesHtml += '<td style="padding: 8px; border: 1px solid #e2e8f0; font-weight: 700; color: #0f1e36;">' + (cp.BookNo || res.BookNo || '-').toUpperCase() + '</td>';
                            copiesHtml += '<td style="padding: 8px; border: 1px solid #e2e8f0;">' + (cp.Condition || 'NEW').toUpperCase() + '</td>';
                            copiesHtml += '<td style="padding: 8px; border: 1px solid #e2e8f0;">' + statusBadge + '</td>';
                            copiesHtml += '<td style="padding: 8px; border: 1px solid #e2e8f0;">' + (cp.ShelfAddress || 'UNASSIGNED').toUpperCase() + '</td>';
                            copiesHtml += '</tr>';
                        });

                        copiesHtml += '</tbody></table>';
                    } else {
                        copiesHtml = '<div style="padding: 12px; color: #64748b; font-style: italic; background: #f8fafc; border-radius: 6px;">NO PHYSICAL COPIES FOUND FOR THIS BOOK.</div>';
                    }

                    document.getElementById('modalCopiesTable').innerHTML = copiesHtml;
                });
            }

            function closeBookModal() {
                var modal = document.getElementById('mdlBookDetail');
                if (modal) modal.style.display = 'none';
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

                input.addEventListener('keydown', function (e) {
                    if (e.key === 'Escape') {
                        suggestions.style.display = 'none';
                    }
                });
            }

            function initAutocomplete() {
                setupAutocomplete('<%= txtPublisher.ClientID %>', 'publisherSuggestions', 'GetPublisherSuggestions', null);
            }

            // Initial binding
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', function () {
                    initAutocomplete();
                });
            } else {
                initAutocomplete();
            }

            // Print functions for redirection success alert
            function printBookCopies(bookID) {
                callWebMethod('GetBookCopiesForPrinting', { bookID: bookID }, function (res) {
                    if (!res) {
                        alert("Error: Book details not found.");
                        return;
                    }
                    printCopyQrsEx(
                        res.Title,
                        res.Authors,
                        res.Copies,
                        res.PrintBookDetail,
                        res.IsAdults,
                        res.IsChildren,
                        res.AcqNo || res.BookNo,
                        res.PurchaseDate,
                        res.Copies.length > 0 ? res.Copies[0].Condition : "New",
                        res.BookNo
                    );
                });
            }

            function printCopyQrsEx(bookTitle, bookAuthors, copies, printDetails, isAdults, isChildren, bookNoVal, receiptDate, conditionVal, bookID) {
                var suitability = "Adults & Children";
                if (isAdults && isChildren) suitability = "Adults & Children";
                else if (isAdults) suitability = "Adults only";
                else if (isChildren) suitability = "Children";

                bookNoVal = bookNoVal || bookID;

                if (!receiptDate) {
                    var today = new Date();
                    var dd = String(today.getDate()).padStart(2, '0');
                    var mm = String(today.getMonth() + 1).padStart(2, '0');
                    var yyyy = today.getFullYear();
                    receiptDate = dd + '/' + mm + '/' + yyyy;
                }

                if (!conditionVal) conditionVal = "New";

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
                    html += '.regulations-title { font-weight: 700; font-size: 12px; text-transform: uppercase; color: #0f1e36; margin-top: 16px; margin-bottom: 6px; letter-spacing: 0.5px; }';
                    html += '.regulations-list { font-size: 10.5px; color: #334155; line-height: 1.4; text-align: justify; margin: 0; padding: 0; }';
                    html += '.regulations-list p { margin: 0 0 6px; }';
                    html += '.regulations-list ol { margin: 0 0 6px; padding-left: 15px; }';
                    html += '.regulations-list li { margin-bottom: 4px; }';
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

                        html += '<div class="regulations-title">Library Regulation:</div>';
                        html += '<div class="regulations-list">';
                        html += '<ol>';
                        html += '<li>Library cards must be made out by all members withdrawing books separate cards can be made for children.</li>';
                        html += '<li>Single members will be allowed to take out 3 books at one time, of which one can be a new book.</li>';
                        html += '<li>Family members are allowed to take out 3 books at one time in addition they can take out 2 children\'s books. Not more then one book of each category can be a new book.</li>';
                        html += '<li>New books can be kept for a maximum of 14 days and this period can only be extended anew for 7 days, if there is no demand for the book from another member</li>';
                        html += '</ol>';
                        html += '<p style="margin-bottom:6px">other books can be kept for 30 days</p>';
                        html += '<p style="margin-bottom:6px">all books taken out must be returned to the Librarian and under no circumstances should be placed on shelves</p>';
                        html += '<p style="margin-bottom:6px">FINES, as approved by the Club will be automatically charged if books are not returned on the due date. A book can be brought in to the Library within the due date and taken out again if there is no demand for it from another member</p>';
                        html += '<p style="margin-bottom:6px">A member who returns a book in a damaged condition will be liable for the cost of (a) rebinding the book or (b) replacing the book. The decision of the Convenor Library as to in which category the damage falls, shall be final.</p>';
                        html += '<p style="margin-bottom:6px">All books lost will be charged their original cost price plus 200% extra to cover enchance in price and the cost of replacement.</p>';
                        html += '<p style="margin-bottom:6px">Books kept in the Reference section may not be taken from the Library, but must be read on the premises.</p>';
                        html += '<p style="margin-bottom:6px">Books contained in the Rare Book section can only be read on the premises. However copies of pages can be make for members or scholars approaching through members, at a standard rate per page approved by the Library Committee from time to time.</p>';
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

            // UpdatePanel PageRequestManager hooks
            if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                    initAutocomplete();
                });
            }
        </script>

    </asp:Content>