<%@ page language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" autoeventwireup="true" CodeFile="Reports.aspx.cs" Inherits="Pages_Reports_Reports" title="Reports & Analytics - Lahore Gymkhana Library" %>

<asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        /* Minimal stylesheet for print layout */
        @media print {
            @page {
                size: landscape;
                margin: 0.4in;
            }
            aside, header, .filter-container, .btn-action-primary, .btn-action-gold, .btn-action-pdf, .filter-group, #tabHeaders, .no-print {
                display: none !important;
            }
            .print-only {
                display: block !important;
            }
            main {
                margin-left: 0 !important;
                padding: 0 !important;
            }
            .tab-pane {
                display: none !important;
            }
            .tab-pane.active-print {
                display: block !important;
            }
            .report-grid-wrapper {
                overflow: visible !important;
                border: none !important;
                margin-top: 0 !important;
            }
            .report-grid {
                width: 100% !important;
                max-width: 100% !important;
                border: 1px solid #cbd5e1 !important;
                margin-top: 10px !important;
                table-layout: auto !important;
                word-break: break-word !important;
            }
            .report-grid th {
                background-color: #0f1e36 !important;
                color: #ffffff !important;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
                padding: 6px 8px !important;
                font-size: 10px !important;
                white-space: normal !important;
                word-wrap: break-word !important;
            }
            .report-grid td {
                padding: 6px 8px !important;
                font-size: 10px !important;
                border-bottom: 1px solid #e2e8f0 !important;
                white-space: normal !important;
                word-wrap: break-word !important;
            }
            .report-table-title {
                margin-top: 15px !important;
                margin-bottom: 10px !important;
                font-size: 15px !important;
                color: #0f1e36 !important;
                border-bottom: 2px solid #c5a059 !important;
                padding-bottom: 5px !important;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">

<!-- Header -->
<div class="no-print" style="background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; padding: 20px 28px; border-radius: 8px; margin-bottom: 24px; border-bottom: 3px solid #c5a059; display: flex; justify-content: space-between; align-items: center; width: 100%; box-sizing: border-box;">
    <div style="display: block;">
        <h2 style="margin: 0; font-size: 22px; font-weight: 600;">Reports & Analytics</h2>
        <p style="margin: 4px 0 0; opacity: .8; font-size: 13px; font-weight: 300;">Lahore Gymkhana Club - Analytical intelligence & inventory reporting engine</p>
    </div>
</div>

<!-- Print-Only Letterhead -->
<div class="print-only" style="margin-bottom: 20px; border-bottom: 2px solid #cbd5e1; padding-bottom: 10px; text-align: left; width: 100%;">
    <img src='<%= ResolveUrl("~/Library Management/Images/logo_new.png") %>' alt="Lahore Gymkhana Logo" style="height: 65px; display: inline-block; margin: 0; object-fit: contain;" />
</div>

<!-- Alert Panel -->
<asp:Panel ID="pnlAlert" runat="server" Visible="false" style="width: 100%;">
    <div id="divAlert" runat="server" style="padding: 16px 24px; border-radius: 8px; font-size: 14px; margin-bottom: 24px; border-left: 4px solid transparent; width: 100%; box-sizing: border-box;">
        <asp:Literal ID="litAlertMsg" runat="server" />
    </div>
</asp:Panel>

<!-- Master Card Tab Control -->
<div style="display: flex; flex-direction: column; width: 100%; max-width: 100%; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 1px 2px 0 rgba(0,0,0,0.05); overflow: hidden; margin-bottom: 30px; box-sizing: border-box;">
    
    <!-- Horizontally Scrollable Tab Headers -->
    <div style="display: flex; background-color: #f8fafc; border-bottom: 1px solid #e2e8f0; width: 100%; max-width: 100%; box-sizing: border-box; overflow-x: auto; white-space: nowrap; scrollbar-width: thin;" id="tabHeaders">
        <button type="button" class="tab-header-btn" style="padding: 18px 20px; text-align: center; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #c5a059; border-bottom: 3px solid #c5a059; background-color: #ffffff; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;" onclick="switchTab(0)">Author-Wise</button>
        <button type="button" class="tab-header-btn" style="padding: 18px 20px; text-align: center; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;" onclick="switchTab(1)">Publisher-Wise</button>
        <button type="button" class="tab-header-btn" style="padding: 18px 20px; text-align: center; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;" onclick="switchTab(2)">Edition-Wise</button>
        <button type="button" class="tab-header-btn" style="padding: 18px 20px; text-align: center; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;" onclick="switchTab(3)">Language-Wise</button>
        <button type="button" class="tab-header-btn" style="padding: 18px 20px; text-align: center; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;" onclick="switchTab(4)">Book Issuance</button>
        <button type="button" class="tab-header-btn" style="padding: 18px 20px; text-align: center; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;" onclick="switchTab(5)">Issued Not Returned</button>
        <button type="button" class="tab-header-btn" style="padding: 18px 20px; text-align: center; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;" onclick="switchTab(6)">Fine Report</button>
        <button type="button" class="tab-header-btn" style="padding: 18px 20px; text-align: center; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;" onclick="switchTab(7)">Member-Wise</button>
        <button type="button" class="tab-header-btn" style="padding: 18px 20px; text-align: center; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;" onclick="switchTab(8)">Books Catalogue</button>
        <button type="button" class="tab-header-btn" style="padding: 18px 20px; text-align: center; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;" onclick="switchTab(9)">Reservations</button>
        <button type="button" class="tab-header-btn" style="padding: 18px 20px; text-align: center; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;" onclick="switchTab(10)">Shelf Books</button>
    </div>

    <!-- Active Tab Hidden Field Tracker -->
    <asp:HiddenField ID="hfActiveTab" runat="server" Value="0" />

    <!-- Content Card Body -->
    <div style="padding: 30px; width: 100%; box-sizing: border-box;">

        <!-- TAB 0: AUTHOR-WISE -->
        <div id="paneAuthorWise" class="tab-pane" style="display: block; width: 100%;">
            <div class="filter-container" style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px; width: 100%; box-sizing: border-box;">
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; align-items: end; width: 100%; box-sizing: border-box;">
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Filter by Author</span>
                        <asp:TextBox ID="txtAuthorFilter" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Type author name..." autocomplete="off" list="dlAuthors" oninput="fetchAuthors(this.value)" />
                        <datalist id="dlAuthors"></datalist>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Category</span>
                        <asp:DropDownList ID="ddlAuthorCategory" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Language</span>
                        <asp:DropDownList ID="ddlAuthorLanguage" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; max-width: 150px; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Publish Year</span>
                        <asp:TextBox ID="txtAuthorYear" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="e.g. 2020" Type="Number" min="1000" max="2100" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Title / ISBN</span>
                        <asp:TextBox ID="txtAuthorTitleKeyword" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Search title or ISBN..." />
                    </div>
                </div>
                <div style="display: flex; gap: 12px; justify-content: flex-end; flex-wrap: wrap; border-top: 1px solid #e2e8f0; padding-top: 16px; box-sizing: border-box;">
                    <asp:Button ID="btnGenerateAuthorWise" runat="server" Text="Generate Report" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnGenerateAuthorWise_Click" />
                    <asp:Button ID="btnExportAuthorWise" runat="server" Text="Export to Excel" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(197, 160, 89, 0.3)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(197, 160, 89, 0.2)';" OnClick="btnExportAuthorWise_Click" />
                    <button type="button" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(0, 0, 0, 0.1)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(0, 0, 0, 0.05)';" onclick="printReport()">Export to PDF</button>
                </div>
            </div>
            
            <h3 class="report-table-title" style="font-size: 15px; margin: 20px 0 12px 0; color: #0f1e36; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Author-Wise Books Inventory</h3>
            <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 20px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                <asp:GridView ID="gvAuthorWise" runat="server"  GridLines="None" AutoGenerateColumns="true" style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;">
                    <HeaderStyle CssClass="gv-header-left" />
                    <RowStyle CssClass="gv-row" />
                    <AlternatingRowStyle CssClass="gv-alt-row" />
                    <EmptyDataTemplate>
                        <div style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff; border: none;">No records found matching the criteria.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

        <!-- TAB 1: PUBLISHER-WISE -->
        <div id="panePublisherWise" class="tab-pane" style="display: none; width: 100%;">
            <div class="filter-container" style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px; width: 100%; box-sizing: border-box;">
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; align-items: end; width: 100%; box-sizing: border-box;">
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Filter by Publisher</span>
                        <asp:TextBox ID="txtPublisherFilter" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Type publisher name..." autocomplete="off" list="dlPublishers" oninput="fetchPublishers(this.value)" />
                        <datalist id="dlPublishers"></datalist>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Category</span>
                        <asp:DropDownList ID="ddlPublisherCategory" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Language</span>
                        <asp:DropDownList ID="ddlPublisherLanguage" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; max-width: 150px; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Publish Year</span>
                        <asp:TextBox ID="txtPublisherYear" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="e.g. 2020" Type="Number" min="1000" max="2100" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Title / ISBN / Author</span>
                        <asp:TextBox ID="txtPublisherTitleKeyword" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Search title, ISBN, or author..." />
                    </div>
                </div>
                <div style="display: flex; gap: 12px; justify-content: flex-end; flex-wrap: wrap; border-top: 1px solid #e2e8f0; padding-top: 16px; box-sizing: border-box;">
                    <asp:Button ID="btnGeneratePublisherWise" runat="server" Text="Generate Report" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnGeneratePublisherWise_Click" />
                    <asp:Button ID="btnExportPublisherWise" runat="server" Text="Export to Excel" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(197, 160, 89, 0.3)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(197, 160, 89, 0.2)';" OnClick="btnExportPublisherWise_Click" />
                    <button type="button" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(0, 0, 0, 0.1)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(0, 0, 0, 0.05)';" onclick="printReport()">Export to PDF</button>
                </div>
            </div>

            <h3 class="report-table-title" style="font-size: 15px; margin: 20px 0 12px 0; color: #0f1e36; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Publisher-Wise Books Inventory</h3>
            <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 20px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                <asp:GridView ID="gvPublisherWise" runat="server"  GridLines="None" AutoGenerateColumns="true" style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;">
                    <HeaderStyle CssClass="gv-header-left" />
                    <RowStyle CssClass="gv-row" />
                    <AlternatingRowStyle CssClass="gv-alt-row" />
                    <EmptyDataTemplate>
                        <div style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff; border: none;">No records found matching the criteria.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

        <!-- TAB 2: EDITION-WISE -->
        <div id="paneEditionWise" class="tab-pane" style="display: none; width: 100%;">
            <div class="filter-container" style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px; width: 100%; box-sizing: border-box;">
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; align-items: end; width: 100%; box-sizing: border-box;">
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Filter by Edition</span>
                        <asp:TextBox ID="txtEditionFilter" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Type edition (e.g. 1st, 2nd, Illustrated)..." />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Category</span>
                        <asp:DropDownList ID="ddlEditionCategory" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Language</span>
                        <asp:DropDownList ID="ddlEditionLanguage" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Title / ISBN / Author / Publisher</span>
                        <asp:TextBox ID="txtEditionKeyword" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Search title, ISBN, author, publisher..." />
                    </div>
                </div>
                <div style="display: flex; gap: 12px; justify-content: flex-end; flex-wrap: wrap; border-top: 1px solid #e2e8f0; padding-top: 16px; box-sizing: border-box;">
                    <asp:Button ID="btnGenerateEditionWise" runat="server" Text="Generate Report" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnGenerateEditionWise_Click" />
                    <asp:Button ID="btnExportEditionWise" runat="server" Text="Export to Excel" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(197, 160, 89, 0.3)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(197, 160, 89, 0.2)';" OnClick="btnExportEditionWise_Click" />
                    <button type="button" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(0, 0, 0, 0.1)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(0, 0, 0, 0.05)';" onclick="printReport()">Export to PDF</button>
                </div>
            </div>

            <h3 class="report-table-title" style="font-size: 15px; margin: 20px 0 12px 0; color: #0f1e36; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Edition-Wise Books Inventory</h3>
            <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 20px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                <asp:GridView ID="gvEditionWise" runat="server"  GridLines="None" AutoGenerateColumns="true" style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;">
                    <HeaderStyle CssClass="gv-header-left" />
                    <RowStyle CssClass="gv-row" />
                    <AlternatingRowStyle CssClass="gv-alt-row" />
                    <EmptyDataTemplate>
                        <div style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff; border: none;">No records found matching the criteria.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

        <!-- TAB 3: LANGUAGE-WISE -->
        <div id="paneLanguageWise" class="tab-pane" style="display: none; width: 100%;">
            <div class="filter-container" style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px; width: 100%; box-sizing: border-box;">
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; align-items: end; width: 100%; box-sizing: border-box;">
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Filter by Language</span>
                        <asp:DropDownList ID="ddlLanguageFilter" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Category</span>
                        <asp:DropDownList ID="ddlLanguageCategory" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Publisher</span>
                        <asp:TextBox ID="txtLanguagePublisherFilter" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Type publisher name..." autocomplete="off" list="dlPublishers" oninput="fetchPublishers(this.value)" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Title / ISBN / Author</span>
                        <asp:TextBox ID="txtLanguageKeyword" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Search title, ISBN, author..." />
                    </div>
                </div>
                <div style="display: flex; gap: 12px; justify-content: flex-end; flex-wrap: wrap; border-top: 1px solid #e2e8f0; padding-top: 16px; box-sizing: border-box;">
                    <asp:Button ID="btnGenerateLanguageWise" runat="server" Text="Generate Report" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnGenerateLanguageWise_Click" />
                    <asp:Button ID="btnExportLanguageWise" runat="server" Text="Export to Excel" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(197, 160, 89, 0.3)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(197, 160, 89, 0.2)';" OnClick="btnExportLanguageWise_Click" />
                    <button type="button" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(0, 0, 0, 0.1)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(0, 0, 0, 0.05)';" onclick="printReport()">Export to PDF</button>
                </div>
            </div>

            <h3 class="report-table-title" style="font-size: 15px; margin: 20px 0 12px 0; color: #0f1e36; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Language-Wise Books Catalogue</h3>
            <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 20px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                <asp:GridView ID="gvLanguageWise" runat="server"  GridLines="None" AutoGenerateColumns="true" style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;">
                    <HeaderStyle CssClass="gv-header-left" />
                    <RowStyle CssClass="gv-row" />
                    <AlternatingRowStyle CssClass="gv-alt-row" />
                    <EmptyDataTemplate>
                        <div style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff; border: none;">No records found matching the criteria.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

        <!-- TAB 4: BOOK ISSUANCE -->
        <div id="paneBookIssuance" class="tab-pane" style="display: none; width: 100%;">
            <div class="filter-container" style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px; width: 100%; box-sizing: border-box;">
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; align-items: end; width: 100%; box-sizing: border-box;">
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; max-width: 150px; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">From Issue Date</span>
                        <asp:TextBox ID="txtIssuanceFrom" runat="server" TextMode="Date" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; max-width: 150px; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">To Issue Date</span>
                        <asp:TextBox ID="txtIssuanceTo" runat="server" TextMode="Date" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; max-width: 150px; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Issuance No</span>
                        <asp:TextBox ID="txtIssuanceNoFilter" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Issuance #" Type="Number" min="1" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Gymkhana Member</span>
                        <asp:TextBox ID="txtIssuanceMemberFilter" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Type member name or number..." autocomplete="off" list="dlMembers" oninput="fetchMembers(this.value)" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Book Title / Barcode</span>
                        <asp:TextBox ID="txtIssuanceBookKeyword" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Search title or barcode..." />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Status</span>
                        <asp:DropDownList ID="ddlIssuanceStatus" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';">
                            <asp:ListItem Value="" Selected="True">-- All Statuses --</asp:ListItem>
                            <asp:ListItem Value="Issued">Issued</asp:ListItem>
                            <asp:ListItem Value="Overdue">Overdue</asp:ListItem>
                            <asp:ListItem Value="Returned">Returned</asp:ListItem>
                            <asp:ListItem Value="Renewed">Renewed</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Issued By Staff</span>
                        <asp:DropDownList ID="ddlIssuanceStaff" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                </div>
                <div style="display: flex; gap: 12px; justify-content: flex-end; flex-wrap: wrap; border-top: 1px solid #e2e8f0; padding-top: 16px; box-sizing: border-box;">
                    <asp:Button ID="btnGenerateBookIssuance" runat="server" Text="Generate Report" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnGenerateBookIssuance_Click" />
                    <asp:Button ID="btnExportBookIssuance" runat="server" Text="Export to Excel" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(197, 160, 89, 0.3)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(197, 160, 89, 0.2)';" OnClick="btnExportBookIssuance_Click" />
                    <button type="button" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(0, 0, 0, 0.1)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(0, 0, 0, 0.05)';" onclick="printReport()">Export to PDF</button>
                </div>
            </div>

            <h3 class="report-table-title" style="font-size: 15px; margin: 20px 0 12px 0; color: #0f1e36; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Book Issuance History</h3>
            <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 20px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                <asp:GridView ID="gvBookIssuance" runat="server"  GridLines="None" AutoGenerateColumns="true" style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;">
                    <HeaderStyle CssClass="gv-header-left" />
                    <RowStyle CssClass="gv-row" />
                    <AlternatingRowStyle CssClass="gv-alt-row" />
                    <EmptyDataTemplate>
                        <div style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff; border: none;">No records found matching the criteria.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

        <!-- TAB 5: ISSUED BUT NOT RETURNED -->
        <div id="paneIssuedNotReturned" class="tab-pane" style="display: none; width: 100%;">
            <div class="filter-container" style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px; width: 100%; box-sizing: border-box;">
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; align-items: end; width: 100%; box-sizing: border-box;">
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Gymkhana Member</span>
                        <asp:TextBox ID="txtIssuedNotReturnedMemberFilter" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Type member name or number..." autocomplete="off" list="dlMembers" oninput="fetchMembers(this.value)" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Book Title / Barcode</span>
                        <asp:TextBox ID="txtIssuedNotReturnedBookKeyword" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Search title or barcode..." />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Overdue Status</span>
                        <asp:DropDownList ID="ddlIssuedNotReturnedOverdueStatus" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';">
                            <asp:ListItem Value="" Selected="True">-- All Checked Out --</asp:ListItem>
                            <asp:ListItem Value="Overdue">Overdue Only</asp:ListItem>
                            <asp:ListItem Value="NotOverdue">Not Overdue Only</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Issued By Staff</span>
                        <asp:DropDownList ID="ddlIssuedNotReturnedStaff" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                </div>
                <div style="display: flex; gap: 12px; justify-content: flex-end; flex-wrap: wrap; border-top: 1px solid #e2e8f0; padding-top: 16px; box-sizing: border-box;">
                    <asp:Button ID="btnGenerateIssuedNotReturned" runat="server" Text="Generate Report" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnGenerateIssuedNotReturned_Click" />
                    <asp:Button ID="btnExportIssuedNotReturned" runat="server" Text="Export to Excel" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(197, 160, 89, 0.3)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(197, 160, 89, 0.2)';" OnClick="btnExportIssuedNotReturned_Click" />
                    <button type="button" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(0, 0, 0, 0.1)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(0, 0, 0, 0.05)';" onclick="printReport()">Export to PDF</button>
                </div>
            </div>

            <h3 class="report-table-title" style="font-size: 15px; margin: 20px 0 12px 0; color: #0f1e36; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Currently Issued Books (Not Returned)</h3>
            <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 20px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                <asp:GridView ID="gvIssuedNotReturned" runat="server"  GridLines="None" AutoGenerateColumns="true" style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;">
                    <HeaderStyle CssClass="gv-header-left" />
                    <RowStyle CssClass="gv-row" />
                    <AlternatingRowStyle CssClass="gv-alt-row" />
                    <EmptyDataTemplate>
                        <div style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff; border: none;">No records found matching the criteria.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

        <!-- TAB 6: FINE REPORT -->
        <div id="paneFineReport" class="tab-pane" style="display: none; width: 100%;">
            <div class="filter-container" style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px; width: 100%; box-sizing: border-box;">
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; align-items: end; width: 100%; box-sizing: border-box;">
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; max-width: 150px; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">From Date (Fine Assessed)</span>
                        <asp:TextBox ID="txtFinesFrom" runat="server" TextMode="Date" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; max-width: 150px; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">To Date (Fine Assessed)</span>
                        <asp:TextBox ID="txtFinesTo" runat="server" TextMode="Date" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Payment Status</span>
                        <asp:DropDownList ID="ddlFinesStatus" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';">
                            <asp:ListItem Value="" Selected="True">All Fines (Paid & Unpaid)</asp:ListItem>
                            <asp:ListItem Value="1">Paid Fines Only</asp:ListItem>
                            <asp:ListItem Value="0">Unpaid Fines Only</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Gymkhana Member</span>
                        <asp:TextBox ID="txtFinesMemberFilter" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Type member name or number..." autocomplete="off" list="dlMembers" oninput="fetchMembers(this.value)" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Book Title / Barcode</span>
                        <asp:TextBox ID="txtFinesBookKeyword" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Search title or barcode..." />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Fine Reason</span>
                        <asp:DropDownList ID="ddlFinesReason" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';">
                            <asp:ListItem Value="" Selected="True">-- All Reasons --</asp:ListItem>
                            <asp:ListItem Value="Overdue">Overdue</asp:ListItem>
                            <asp:ListItem Value="Lost Book">Lost Book</asp:ListItem>
                            <asp:ListItem Value="Damage">Damage</asp:ListItem>
                            <asp:ListItem Value="Other">Other</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; max-width: 150px; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Min Fine Amount</span>
                        <asp:TextBox ID="txtFinesMinAmount" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Min amount" Type="Number" min="0" />
                    </div>
                </div>
                <div style="display: flex; gap: 12px; justify-content: flex-end; flex-wrap: wrap; border-top: 1px solid #e2e8f0; padding-top: 16px; box-sizing: border-box;">
                    <asp:Button ID="btnGenerateFines" runat="server" Text="Generate Report" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnGenerateFines_Click" />
                    <asp:Button ID="btnExportFines" runat="server" Text="Export to Excel" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(197, 160, 89, 0.3)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(197, 160, 89, 0.2)';" OnClick="btnExportFines_Click" />
                    <button type="button" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(0, 0, 0, 0.1)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(0, 0, 0, 0.05)';" onclick="printReport()">Export to PDF</button>
                </div>
            </div>

            <h3 class="report-table-title" style="font-size: 15px; margin: 20px 0 12px 0; color: #0f1e36; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Fines & Penalties Report</h3>
            <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 20px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                <asp:GridView ID="gvFines" runat="server"  GridLines="None" AutoGenerateColumns="true" style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;">
                    <HeaderStyle CssClass="gv-header-left" />
                    <RowStyle CssClass="gv-row" />
                    <AlternatingRowStyle CssClass="gv-alt-row" />
                    <EmptyDataTemplate>
                        <div style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff; border: none;">No records found matching the criteria.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

        <!-- TAB 7: MEMBER-WISE BORROWING -->
        <div id="paneMemberWise" class="tab-pane" style="display: none; width: 100%;">
            <div class="filter-container" style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px; width: 100%; box-sizing: border-box;">
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; align-items: end; width: 100%; box-sizing: border-box;">
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Filter by Gymkhana Member</span>
                        <asp:TextBox ID="txtMemberFilter" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Type member name or number (e.g. P-3219)..." autocomplete="off" list="dlMembers" oninput="fetchMembers(this.value)" />
                        <datalist id="dlMembers"></datalist>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Book Title / Barcode</span>
                        <asp:TextBox ID="txtMemberBookKeyword" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Search title or barcode..." />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; max-width: 150px; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">From Issue Date</span>
                        <asp:TextBox ID="txtMemberFromDate" runat="server" TextMode="Date" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; max-width: 150px; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">To Issue Date</span>
                        <asp:TextBox ID="txtMemberToDate" runat="server" TextMode="Date" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Loan Status</span>
                        <asp:DropDownList ID="ddlMemberLoanStatus" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';">
                            <asp:ListItem Value="" Selected="True">-- All Statuses --</asp:ListItem>
                            <asp:ListItem Value="Issued">Issued</asp:ListItem>
                            <asp:ListItem Value="Overdue">Overdue</asp:ListItem>
                            <asp:ListItem Value="Returned">Returned</asp:ListItem>
                            <asp:ListItem Value="Renewed">Renewed</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div style="display: flex; gap: 12px; justify-content: flex-end; flex-wrap: wrap; border-top: 1px solid #e2e8f0; padding-top: 16px; box-sizing: border-box;">
                    <asp:Button ID="btnGenerateMemberWise" runat="server" Text="Generate Report" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnGenerateMemberWise_Click" />
                    <asp:Button ID="btnExportMemberWise" runat="server" Text="Export to Excel" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(197, 160, 89, 0.3)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(197, 160, 89, 0.2)';" OnClick="btnExportMemberWise_Click" />
                    <button type="button" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(0, 0, 0, 0.1)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(0, 0, 0, 0.05)';" onclick="printReport()">Export to PDF</button>
                </div>
            </div>

            <h3 class="report-table-title" style="font-size: 15px; margin: 20px 0 12px 0; color: #0f1e36; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Member-Wise Borrowing History</h3>
            <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 20px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                <asp:GridView ID="gvMemberWise" runat="server"  GridLines="None" AutoGenerateColumns="true" style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;">
                    <HeaderStyle CssClass="gv-header-left" />
                    <RowStyle CssClass="gv-row" />
                    <AlternatingRowStyle CssClass="gv-alt-row" />
                    <EmptyDataTemplate>
                        <div style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff; border: none;">No records found matching the criteria.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

        <!-- TAB 8: BOOKS REPORT -->
        <div id="paneBooksReport" class="tab-pane" style="display: none; width: 100%;">
            <div class="filter-container" style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px; width: 100%; box-sizing: border-box;">
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; align-items: end; width: 100%; box-sizing: border-box;">
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Category</span>
                        <asp:DropDownList ID="ddlBooksCategory" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Language</span>
                        <asp:DropDownList ID="ddlBooksLanguage" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Publisher</span>
                        <asp:TextBox ID="txtBooksPublisherFilter" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Type publisher name..." autocomplete="off" list="dlPublishers" oninput="fetchPublishers(this.value)" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Title / ISBN / Author</span>
                        <asp:TextBox ID="txtBooksKeyword" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Search title, ISBN, or author..." />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Availability</span>
                        <asp:DropDownList ID="ddlBooksAvailability" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';">
                            <asp:ListItem Value="" Selected="True">-- All Books --</asp:ListItem>
                            <asp:ListItem Value="Available">Available Copies > 0</asp:ListItem>
                            <asp:ListItem Value="Unavailable">Out of Stock Only</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div style="display: flex; gap: 12px; justify-content: flex-end; flex-wrap: wrap; border-top: 1px solid #e2e8f0; padding-top: 16px; box-sizing: border-box;">
                    <asp:Button ID="btnGenerateBooks" runat="server" Text="Generate Report" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnGenerateBooks_Click" />
                    <asp:Button ID="btnExportBooks" runat="server" Text="Export to Excel" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(197, 160, 89, 0.3)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(197, 160, 89, 0.2)';" OnClick="btnExportBooks_Click" />
                    <button type="button" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(0, 0, 0, 0.1)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(0, 0, 0, 0.05)';" onclick="printReport()">Export to PDF</button>
                </div>
            </div>

            <h3 class="report-table-title" style="font-size: 15px; margin: 20px 0 12px 0; color: #0f1e36; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Complete Books Catalogue</h3>
            <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 20px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                <asp:GridView ID="gvBooks" runat="server"  GridLines="None" AutoGenerateColumns="true" style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;">
                    <HeaderStyle CssClass="gv-header-left" />
                    <RowStyle CssClass="gv-row" />
                    <AlternatingRowStyle CssClass="gv-alt-row" />
                    <EmptyDataTemplate>
                        <div style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff; border: none;">No records found matching the criteria.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

        <!-- TAB 9: RESERVATIONS REPORT -->
        <div id="paneReservations" class="tab-pane" style="display: none; width: 100%;">
            <div class="filter-container" style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px; width: 100%; box-sizing: border-box;">
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; align-items: end; width: 100%; box-sizing: border-box;">
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; max-width: 150px; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">From Reserved Date</span>
                        <asp:TextBox ID="txtReservationsFrom" runat="server" TextMode="Date" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; max-width: 150px; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">To Reserved Date</span>
                        <asp:TextBox ID="txtReservationsTo" runat="server" TextMode="Date" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Status</span>
                        <asp:DropDownList ID="ddlReservationsStatus" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';">
                            <asp:ListItem Value="" Selected="True">All Statuses</asp:ListItem>
                            <asp:ListItem Value="1">Active</asp:ListItem>
                            <asp:ListItem Value="2">Fulfilled</asp:ListItem>
                            <asp:ListItem Value="3">Cancelled</asp:ListItem>
                            <asp:ListItem Value="4">Expired</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Gymkhana Member</span>
                        <asp:TextBox ID="txtReservationsMemberFilter" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Type member name or number..." autocomplete="off" list="dlMembers" oninput="fetchMembers(this.value)" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Book Title</span>
                        <asp:TextBox ID="txtReservationsBookKeyword" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Search book title..." />
                    </div>
                </div>
                <div style="display: flex; gap: 12px; justify-content: flex-end; flex-wrap: wrap; border-top: 1px solid #e2e8f0; padding-top: 16px; box-sizing: border-box;">
                    <asp:Button ID="btnGenerateReservations" runat="server" Text="Generate Report" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnGenerateReservations_Click" />
                    <asp:Button ID="btnExportReservations" runat="server" Text="Export to Excel" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(197, 160, 89, 0.3)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(197, 160, 89, 0.2)';" OnClick="btnExportReservations_Click" />
                    <button type="button" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(0, 0, 0, 0.1)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(0, 0, 0, 0.05)';" onclick="printReport()">Export to PDF</button>
                </div>
            </div>

            <h3 class="report-table-title" style="font-size: 15px; margin: 20px 0 12px 0; color: #0f1e36; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Book Reservations History</h3>
            <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 20px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                <asp:GridView ID="gvReservations" runat="server"  GridLines="None" AutoGenerateColumns="true" style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;">
                    <HeaderStyle CssClass="gv-header-left" />
                    <RowStyle CssClass="gv-row" />
                    <AlternatingRowStyle CssClass="gv-alt-row" />
                    <EmptyDataTemplate>
                        <div style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff; border: none;">No records found matching the criteria.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

        <!-- TAB 10: SHELF BOOKS REPORT -->
        <div id="paneShelfBooks" class="tab-pane" style="display: none; width: 100%;">
            <div class="filter-container" style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px; width: 100%; box-sizing: border-box;">
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; align-items: end; width: 100%; box-sizing: border-box;">
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Hall</span>
                        <asp:DropDownList ID="ddlShelfHall" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; max-width: 150px; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Aisle / Unit</span>
                        <asp:TextBox ID="txtShelfAisle" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="e.g. A-01" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; max-width: 150px; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Rack #</span>
                        <asp:TextBox ID="txtShelfRack" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Rack number" Type="Number" min="1" />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Book Title / Barcode</span>
                        <asp:TextBox ID="txtShelfKeyword" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Search title or barcode..." />
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Status</span>
                        <asp:DropDownList ID="ddlShelfAvailability" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';">
                            <asp:ListItem Value="" Selected="True">-- All copies --</asp:ListItem>
                            <asp:ListItem Value="On Shelf">On Shelf Only</asp:ListItem>
                            <asp:ListItem Value="Checked Out">Checked Out Only</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div style="display: flex; gap: 12px; justify-content: flex-end; flex-wrap: wrap; border-top: 1px solid #e2e8f0; padding-top: 16px; box-sizing: border-box;">
                    <asp:Button ID="btnGenerateShelfBooks" runat="server" Text="Generate Report" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnGenerateShelfBooks_Click" />
                    <asp:Button ID="btnExportShelfBooks" runat="server" Text="Export to Excel" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(197, 160, 89, 0.3)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(197, 160, 89, 0.2)';" OnClick="btnExportShelfBooks_Click" />
                    <button type="button" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(0, 0, 0, 0.1)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(0, 0, 0, 0.05)';" onclick="printReport()">Export to PDF</button>
                </div>
            </div>

            <h3 class="report-table-title" style="font-size: 15px; margin: 20px 0 12px 0; color: #0f1e36; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Physical Shelf Books Mapping</h3>
            <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 20px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                <asp:GridView ID="gvShelfBooks" runat="server"  GridLines="None" AutoGenerateColumns="true" style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;">
                    <HeaderStyle CssClass="gv-header-left" />
                    <RowStyle CssClass="gv-row" />
                    <AlternatingRowStyle CssClass="gv-alt-row" />
                    <EmptyDataTemplate>
                        <div style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff; border: none;">No records found matching the criteria.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

    </div>
</div>

<script>
    // Tab switching mechanism
    function switchTab(index) {
        var btns = document.querySelectorAll('.tab-header-btn');
        for (var i = 0; i < btns.length; i++) {
            btns[i].style.color = '#64748b';
            btns[i].style.borderBottomColor = 'transparent';
            btns[i].style.backgroundColor = 'transparent';
        }
        btns[index].style.color = '#c5a059';
        btns[index].style.borderBottomColor = '#c5a059';
        btns[index].style.backgroundColor = '#ffffff';

        var panes = document.querySelectorAll('.tab-pane');
        for (var i = 0; i < panes.length; i++) {
            panes[i].style.display = 'none';
        }
        panes[index].style.display = 'block';

        var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
        if (hf) {
            hf.value = index;
        }
    }

    // Native browser print helper
    function printReport() {
        var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
        var activeIdx = hf ? parseInt(hf.value) : 0;
        var panes = document.querySelectorAll('.tab-pane');
        
        for (var i = 0; i < panes.length; i++) {
            panes[i].classList.remove('active-print');
        }
        
        if (panes[activeIdx]) {
            panes[activeIdx].classList.add('active-print');
        }
        
        // Set dynamic date stamp for printed page
        var printDateEl = document.getElementById('printDate');
        if (printDateEl) {
            var now = new Date();
            printDateEl.textContent = now.toLocaleDateString() + ' ' + now.toLocaleTimeString();
        }
        
        window.print();
    }

    // Restore active tab state on DOM load
    document.addEventListener('DOMContentLoaded', function() {
        var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
        if (hf && hf.value !== '') {
            var activeIdx = parseInt(hf.value);
            if (!isNaN(activeIdx)) {
                switchTab(activeIdx);
            }
        }
    });

    // Auto Extender functionality for Member Search
    let memberSearchTimeout;
    function fetchMembers(term) {
        if (term.length < 2) {
            document.getElementById('dlMembers').innerHTML = '';
            return;
        }
        clearTimeout(memberSearchTimeout);
        memberSearchTimeout = setTimeout(() => {
            fetch('Reports.aspx/GetMemberSuggestions', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ term: term })
            })
            .then(res => res.json())
            .then(data => {
                const dl = document.getElementById('dlMembers');
                dl.innerHTML = '';
                data.d.forEach(item => {
                    const opt = document.createElement('option');
                    opt.value = item.label;
                    dl.appendChild(opt);
                });
            })
            .catch(err => console.error('Error fetching members:', err));
        }, 300);
    }

    // Auto Extender functionality for Author Search
    let authorSearchTimeout;
    function fetchAuthors(term) {
        if (term.length < 2) {
            document.getElementById('dlAuthors').innerHTML = '';
            return;
        }
        clearTimeout(authorSearchTimeout);
        authorSearchTimeout = setTimeout(() => {
            fetch('Reports.aspx/GetAuthorSuggestions', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ term: term })
            })
            .then(res => res.json())
            .then(data => {
                const dl = document.getElementById('dlAuthors');
                dl.innerHTML = '';
                data.d.forEach(item => {
                    const opt = document.createElement('option');
                    opt.value = item.label;
                    dl.appendChild(opt);
                });
            })
            .catch(err => console.error('Error fetching authors:', err));
        }, 300);
    }

    // Auto Extender functionality for Publisher Search
    let publisherSearchTimeout;
    function fetchPublishers(term) {
        if (term.length < 2) {
            document.getElementById('dlPublishers').innerHTML = '';
            return;
        }
        clearTimeout(publisherSearchTimeout);
        publisherSearchTimeout = setTimeout(() => {
            fetch('Reports.aspx/GetPublisherSuggestions', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ term: term })
            })
            .then(res => res.json())
            .then(data => {
                const dl = document.getElementById('dlPublishers');
                dl.innerHTML = '';
                data.d.forEach(item => {
                    const opt = document.createElement('option');
                    opt.value = item.label;
                    dl.appendChild(opt);
                });
            })
            .catch(err => console.error('Error fetching publishers:', err));
        }, 300);
    }
</script>

</asp:Content>
