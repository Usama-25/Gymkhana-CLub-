<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master"
    AutoEventWireup="true"
    CodeFile="Rcipecart.aspx.cs"
    Inherits="Store_Cash_Sale_Invoice_Wise" %>

<%-- Register Assembly AjaxControlToolkit disabled --%>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">

<style>
/* ---------------------------------------------------
   BASE
--------------------------------------------------- */
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: 'Segoe UI', Arial, sans-serif; font-size: 12px;
       background: #eef1f6; color: #1a1a2e; }

.page { max-width: 960px; margin: 0 auto; padding: 20px; }

/* ---------------------------------------------------
   SEARCH PANEL  (hidden on print)
--------------------------------------------------- */
.search-card { background:#fff; border:1px solid #dde2ec; border-radius:10px;
               padding:16px 20px; margin-bottom:18px; }
.search-card .card-title { font-size:11px; font-weight:700; color:#666;
                            text-transform:uppercase; letter-spacing:.06em; margin-bottom:12px; }
.search-row { display:flex; gap:10px; flex-wrap:wrap; align-items:flex-end; }
.field { display:flex; flex-direction:column; gap:4px; flex:1; min-width:180px; }
.field label { font-size:10px; font-weight:700; color:#888;
               text-transform:uppercase; letter-spacing:.05em; }
.field input[type=text] { height:34px; border:1px solid #ccd2de; border-radius:6px;
                           padding:0 10px; font-size:12px; }
.field input[type=text]:focus { outline:none; border-color:#185FA5;
                                 box-shadow:0 0 0 3px rgba(24,95,165,.12); }
.btn-search { height:34px; padding:0 20px; background:#185FA5; color:#fff;
              border:none; border-radius:6px; cursor:pointer; font-size:12px; font-weight:700; }
.btn-search:hover { background:#0C447C; }
.btn-clear  { height:34px; padding:0 14px; background:#f0f2f6; color:#555;
              border:1px solid #ccd2de; border-radius:6px; cursor:pointer; font-size:12px; font-weight:600; }
.btn-print  { height:34px; padding:0 14px; background:#f0f2f6; color:#555;
              border:1px solid #ccd2de; border-radius:6px; cursor:pointer; font-size:12px; font-weight:600; }

/* ---------------------------------------------------
   ALERT
--------------------------------------------------- */
.alert-danger { background:#FCEBEB; border:1px solid #F7C1C1; color:#a32d2d;
                padding:10px 14px; border-radius:8px; margin-bottom:14px; font-weight:600; }

/* ---------------------------------------------------
   RECIPE CARD  — mirrors the printed card in image
--------------------------------------------------- */
.rc-wrap { background:#fff; border:2px solid #1a3a6b;
           border-radius:4px; font-size:11px; color:#111; }

/* -- Top header bar -- */
.rc-topbar { display:flex; align-items:stretch;
             border-bottom:2px solid #1a3a6b; }
.rc-logo-cell { width:64px; min-width:64px; display:flex; align-items:center;
                justify-content:center; border-right:1px solid #1a3a6b; padding:6px; }
.rc-logo-cell img { width:48px; height:48px; object-fit:contain; }
.rc-logo-placeholder { width:48px; height:48px; background:#1a3a6b; border-radius:4px;
                        display:flex; align-items:center; justify-content:center;
                        color:#fff; font-size:18px; font-weight:900; }
.rc-title-cell { flex:1; padding:6px 12px; border-right:1px solid #1a3a6b; }
.rc-title-cell .main-title { font-size:13px; font-weight:800; color:#1a3a6b;
                               text-transform:uppercase; letter-spacing:.04em; }
.rc-title-cell .sub-title  { font-size:10px; color:#555; margin-top:1px; }
.rc-meta-cell { width:280px; min-width:280px; }
.rc-meta-cell table { width:100%; border-collapse:collapse; height:100%; }
.rc-meta-cell td { padding:3px 8px; border-bottom:1px solid #dde; vertical-align:middle; }
.rc-meta-cell td:first-child { font-weight:700; color:#1a3a6b; white-space:nowrap;
                                 width:130px; font-size:10px; }
.rc-meta-cell td:last-child  { font-size:11px; font-weight:600; }
.rc-meta-cell tr:last-child td { border-bottom:none; }

/* -- Section header -- */
.rc-section-hdr { background:#1a3a6b; color:#fff; font-weight:700; font-size:11px;
                   padding:4px 10px; letter-spacing:.04em; text-transform:uppercase;
                   display:flex; justify-content:space-between; align-items:center; }
.rc-section-hdr .sec-right { font-size:10px; font-weight:600; opacity:.85; }

/* -- Grid table -- */
.rc-table { width:100%; border-collapse:collapse; }
.rc-table thead th { background:#dce6f7; color:#1a3a6b; font-size:10px;
                     font-weight:700; padding:5px 8px; border:1px solid #b8c9e8;
                     text-align:right; white-space:nowrap; }
.rc-table thead th.left { text-align:left; }
.rc-table tbody td { padding:4px 8px; font-size:11px; border:1px solid #e4e8f0;
                     text-align:right; vertical-align:middle; }
.rc-table tbody td.left { text-align:left; }
.rc-table tbody tr:nth-child(even) td { background:#f6f8fd; }
.rc-table tbody tr:hover td { background:#edf3ff; }

/* variance colours */
.var-pos  { color:#c0392b; font-weight:700; }
.var-neg  { color:#1D9E75; font-weight:700; }
.var-zero { color:#aaa; }

/* -- Section footer (subtotal row) -- */
.rc-sec-foot { display:flex; justify-content:flex-end; align-items:center;
               padding:5px 10px; background:#edf3ff; border-top:1px solid #b8c9e8;
               border-bottom:2px solid #1a3a6b; font-weight:700; font-size:11px; color:#1a3a6b; }

/* -- Recipe Details block -- */
.rc-details { border-top:2px solid #1a3a6b; display:flex; flex-wrap:wrap; }
.rc-details-left  { flex:1; min-width:220px; padding:10px 14px;
                    border-right:1px solid #dde; }
.rc-details-right { flex:1; min-width:220px; padding:10px 14px; }

.rd-block { margin-bottom:8px; }
.rd-block .rd-title { font-size:10px; font-weight:700; color:#1a3a6b;
                       text-transform:uppercase; letter-spacing:.05em; margin-bottom:4px; }
.rd-row   { display:flex; justify-content:space-between; padding:2px 0;
            border-bottom:1px dotted #dde; font-size:11px; }
.rd-row .rd-label { color:#555; }
.rd-row .rd-val   { font-weight:700; color:#111; }

/* -- Summary metrics row -- */
.rc-summary { border-top:2px solid #1a3a6b; display:grid;
              grid-template-columns:repeat(4,1fr); }
.rc-summary-item { padding:8px 10px; border-right:1px solid #dde; }
.rc-summary-item:last-child { border-right:none; }
.rsi-label { font-size:9px; font-weight:700; color:#888;
              text-transform:uppercase; letter-spacing:.05em; margin-bottom:3px; }
.rsi-val   { font-size:14px; font-weight:800; color:#1a3a6b; }
.rsi-sub   { font-size:9px; color:#aaa; margin-top:1px; }

/* metric colours */
.m-danger  .rsi-val { color:#c0392b; }
.m-success .rsi-val { color:#1D9E75; }
.m-amber   .rsi-val { color:#BA7517; }
.m-info    .rsi-val { color:#185FA5; }
.m-danger  { background:#FCEBEB; }
.m-success { background:#EAF3DE; }
.m-amber   { background:#FAEEDA; }
.m-info    { background:#E6F1FB; }

/* -- Footer bar -- */
.rc-footer { border-top:2px solid #1a3a6b; background:#f0f4fc;
             padding:5px 14px; display:flex; justify-content:space-between;
             font-size:10px; color:#555; }
.rc-footer strong { color:#1a3a6b; }

/* -- Empty state -- */
.empty-state { text-align:center; padding:50px; color:#aaa; background:#fff;
               border-radius:10px; border:1px dashed #ccd; }

/* ---------------------------------------------------
   PRINT  — the key fixes for overlap
--------------------------------------------------- */
@media print {
    /* hide controls */
    .no-print { display:none !important; }

    /* reset layout */
    html, body { background:#fff !important; font-size:10pt; }
    .page { padding:0 !important; max-width:100% !important; }

    /* card fills page */
    .rc-wrap { border:1.5pt solid #1a3a6b !important;
               page-break-inside: avoid; width:100%; }

    /* CRITICAL — prevent text wrapping/overlap in cells */
    .rc-table thead th,
    .rc-table tbody td {
        font-size: 8pt !important;
        padding: 3pt 5pt !important;
        white-space: nowrap !important;
        overflow: hidden !important;
        text-overflow: ellipsis !important;
    }

    /* left-aligned cells may wrap — allow 2 lines max */
    .rc-table tbody td.left,
    .rc-table thead th.left {
        white-space: normal !important;
        max-width: 140pt !important;
        word-break: break-word !important;
    }

    /* summary grid — 4 cols on print */
    .rc-summary { grid-template-columns: repeat(4,1fr) !important; }
    .rsi-val    { font-size:11pt !important; }
    .rsi-label  { font-size:7pt  !important; }

    /* recipe meta */
    .rc-meta-cell td { font-size:8pt !important; padding:2pt 6pt !important; }
    .rc-title-cell .main-title { font-size:11pt !important; }

    /* details rows */
    .rd-row { font-size:8pt !important; }
    .rc-footer { font-size:7pt !important; }

    /* section headers */
    .rc-section-hdr { font-size:9pt !important; padding:3pt 8pt !important; }
    .rc-sec-foot    { font-size:9pt !important; padding:3pt 8pt !important; }

    /* avoid page breaks inside section */
    .rc-wrap > * { page-break-inside: avoid; }
    .rc-details   { page-break-inside: avoid; }

    /* tables — allow page break between rows only */
    .rc-table { page-break-inside: auto; }
    .rc-table tr { page-break-inside: avoid; page-break-after: auto; }
}
</style>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<div class="page">

    <!-- -- Search Panel -- -->
    <div class="search-card no-print">
        <div class="card-title">?? Search Recipe</div>
        <div class="search-row">
            <div class="field">
                <label>Recipe Name</label>
                <asp:TextBox ID="txtName" runat="server" placeholder="e.g. Dynamite Chicken" />
            </div>
            <div class="field">
                <label>Recipe Item Code</label>
                <asp:TextBox ID="txtCode" runat="server" placeholder="e.g. RC-1001" />
            </div>
            <asp:Button ID="btnSearch" runat="server" Text="?? Search"
                CssClass="btn-search" OnClick="btnSearch_Click" />
            <asp:Button ID="btnClear"  runat="server" Text="Clear"
                CssClass="btn-clear"  OnClick="btnClear_Click" CausesValidation="false" />
            <button type="button" class="btn-print" onclick="window.print()">?? Print</button>
        </div>
    </div>

    <!-- -- Alert -- -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <div class="alert-danger">
            <asp:Label ID="lblAlert" runat="server" />
        </div>
    </asp:Panel>

    <!-- ------------------------------------------
         REPORT  — styled as recipe card
    ------------------------------------------ -->
    <asp:Panel ID="pnlReport" runat="server" Visible="false">
    <div class="rc-wrap">

        <!-- -- TOP HEADER BAR -- -->
        <div class="rc-topbar">

            <!-- Logo -->
            <div class="rc-logo-cell">
                <div class="rc-logo-placeholder">??</div>
            </div>

            <!-- Title -->
            <div class="rc-title-cell">
                <div class="main-title">Standard Recipe Card</div>
                <div class="sub-title">Lahore Gymkhana &nbsp;|&nbsp; Live Costing Report</div>
                <div class="sub-title" style="margin-top:3px;color:#185FA5;font-weight:700;">
                    ? LIVE &nbsp;&nbsp;
                    Generated: <asp:Label ID="lblGenDate" runat="server" />
                </div>
            </div>

            <!-- Meta fields -->
            <div class="rc-meta-cell">
                <table>
                    <tr>
                        <td>Dish Name</td>
                        <td><asp:Label ID="lblRecipeName" runat="server" /></td>
                    </tr>
                    <tr>
                        <td>Recipe Code</td>
                        <td><asp:Label ID="lblRecipeCode" runat="server" /></td>
                    </tr>
                    <tr>
                        <td>Category</td>
                        <td>Main Course</td>
                    </tr>
                    <tr>
                        <td>Serving Style</td>
                        <td>1 Portion</td>
                    </tr>
                    <tr>
                        <td>Serving Utensil</td>
                        <td><asp:Label ID="lblUtensil" runat="server" /></td>
                    </tr>
                    <tr>
                        <td>Recipe Weight</td>
                        <td><asp:Label ID="lblWeight" runat="server" /></td>
                    </tr>
                    <tr>
                        <td>Selling Price</td>
                        <td style="color:#185FA5;font-weight:800;">
                            <asp:Label ID="lblSellPrice" runat="server" /></td>
                    </tr>
                </table>
            </div>
        </div><!-- /rc-topbar -->

        <!-- --------------------------
             MAIN INGREDIENTS
        -------------------------- -->
        <asp:Panel ID="pnlMain" runat="server" Visible="false">
            <div class="rc-section-hdr">
                <span>RECIPE INGREDIENTS — Main</span>
                <span class="sec-right">Live Total: <asp:Label ID="lblTotMain" runat="server" /></span>
            </div>
            <div style="overflow-x:auto;">
                <asp:GridView ID="gvMain" runat="server" CssClass="rc-table"
                    AutoGenerateColumns="false" GridLines="None" ShowHeaderWhenEmpty="true">
                    <Columns>
                        <asp:BoundField DataField="ItemCode"       HeaderText="S.No / Code"   HeaderStyle-CssClass="left" ItemStyle-CssClass="left" />
                        <asp:BoundField DataField="ItemName"       HeaderText="Ingredient"    HeaderStyle-CssClass="left" ItemStyle-CssClass="left" />
                        <asp:BoundField DataField="Unit"           HeaderText="Unit"          HeaderStyle-CssClass="left" ItemStyle-CssClass="left" />
                        <asp:BoundField DataField="Quantity"       HeaderText="Quantity"      DataFormatString="{0:N3}" />
                        <asp:BoundField DataField="ConversionFactor"         HeaderText="Factor"        DataFormatString="{0:N0}" />
                        <asp:BoundField DataField="LiveRate"       HeaderText="Rate Per Unit" DataFormatString="{0:N2}" />
                        <asp:BoundField DataField="SavedTotalCost" HeaderText="Saved Cost"    DataFormatString="{0:N2}" />
                        <asp:BoundField DataField="LiveTotalCost"  HeaderText="Live Cost"     DataFormatString="{0:N2}" />
                        <asp:TemplateField HeaderText="Variance">
                            <ItemTemplate>
                                <span class='<%# GetVarianceClass(Eval("Variance")) %>'>
                                    <%# FormatVariance(Eval("Variance")) %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <HeaderStyle   CssClass="rc-thead" />
                    <AlternatingRowStyle BackColor="#f6f8fd" />
                </asp:GridView>
            </div>
            <div class="rc-sec-foot">
                Live Section Total &nbsp; <asp:Label ID="lblTotMain2" runat="server" />
            </div>
        </asp:Panel>

        <!-- --------------------------
             GARNISH
        -------------------------- -->
        <asp:Panel ID="pnlGarnish" runat="server" Visible="false">
            <div class="rc-section-hdr" style="background:#145c3f;">
                <span>ACCOMPANIMENTS / GARNISH</span>
                <span class="sec-right">Live Total: <asp:Label ID="lblTotGarnish" runat="server" /></span>
            </div>
            <div style="overflow-x:auto;">
                <asp:GridView ID="gvGarnish" runat="server" CssClass="rc-table"
                    AutoGenerateColumns="false" GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="ItemCode"       HeaderText="S.No / Code"   HeaderStyle-CssClass="left" ItemStyle-CssClass="left" />
                        <asp:BoundField DataField="ItemName"       HeaderText="Ingredient"    HeaderStyle-CssClass="left" ItemStyle-CssClass="left" />
                        <asp:BoundField DataField="Unit"           HeaderText="Unit"          HeaderStyle-CssClass="left" ItemStyle-CssClass="left" />
                        <asp:BoundField DataField="Quantity"       HeaderText="Quantity"      DataFormatString="{0:N3}" />
                        <asp:BoundField DataField="ConversionFactor"         HeaderText="Factor"        DataFormatString="{0:N0}" />
                        <asp:BoundField DataField="LiveRate"       HeaderText="Rate Per Unit" DataFormatString="{0:N2}" />
                        <asp:BoundField DataField="SavedTotalCost" HeaderText="Saved Cost"    DataFormatString="{0:N2}" />
                        <asp:BoundField DataField="LiveTotalCost"  HeaderText="Live Cost"     DataFormatString="{0:N2}" />
                        <asp:TemplateField HeaderText="Variance">
                            <ItemTemplate>
                                <span class='<%# GetVarianceClass(Eval("Variance")) %>'>
                                    <%# FormatVariance(Eval("Variance")) %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <AlternatingRowStyle BackColor="#f6f8fd" />
                </asp:GridView>
            </div>
            <div class="rc-sec-foot" style="border-color:#145c3f;">
                Live Section Total &nbsp; <asp:Label ID="lblTotGarnish2" runat="server" />
            </div>
        </asp:Panel>

        <!-- --------------------------
             TOPPING
        -------------------------- -->
        <asp:Panel ID="pnlTopping" runat="server" Visible="false">
            <div class="rc-section-hdr" style="background:#7a4e10;">
                <span>TOPPING</span>
                <span class="sec-right">Live Total: <asp:Label ID="lblTotTopping" runat="server" /></span>
            </div>
            <div style="overflow-x:auto;">
                <asp:GridView ID="gvTopping" runat="server" CssClass="rc-table"
                    AutoGenerateColumns="false" GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="ItemCode"       HeaderText="S.No / Code"   HeaderStyle-CssClass="left" ItemStyle-CssClass="left" />
                        <asp:BoundField DataField="ItemName"       HeaderText="Ingredient"    HeaderStyle-CssClass="left" ItemStyle-CssClass="left" />
                        <asp:BoundField DataField="Unit"           HeaderText="Unit"          HeaderStyle-CssClass="left" ItemStyle-CssClass="left" />
                        <asp:BoundField DataField="Quantity"       HeaderText="Quantity"      DataFormatString="{0:N3}" />
                        <asp:BoundField DataField="ConversionFactor"         HeaderText="Factor"        DataFormatString="{0:N0}" />
                        <asp:BoundField DataField="LiveRate"       HeaderText="Rate Per Unit" DataFormatString="{0:N2}" />
                        <asp:BoundField DataField="SavedTotalCost" HeaderText="Saved Cost"    DataFormatString="{0:N2}" />
                        <asp:BoundField DataField="LiveTotalCost"  HeaderText="Live Cost"     DataFormatString="{0:N2}" />
                        <asp:TemplateField HeaderText="Variance">
                            <ItemTemplate>
                                <span class='<%# GetVarianceClass(Eval("Variance")) %>'>
                                    <%# FormatVariance(Eval("Variance")) %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <AlternatingRowStyle BackColor="#f6f8fd" />
                </asp:GridView>
            </div>
            <div class="rc-sec-foot" style="border-color:#7a4e10;">
                Live Section Total &nbsp; <asp:Label ID="lblTotTopping2" runat="server" />
            </div>
        </asp:Panel>

        <!-- --------------------------
             WASTAGE
        -------------------------- -->
        <asp:Panel ID="pnlWastage" runat="server" Visible="false">
            <div class="rc-section-hdr" style="background:#7a1010;">
                <span>WASTAGE</span>
                <span class="sec-right">Live Total: <asp:Label ID="lblTotWastage" runat="server" /></span>
            </div>
            <div style="overflow-x:auto;">
                <asp:GridView ID="gvWastage" runat="server" CssClass="rc-table"
                    AutoGenerateColumns="false" GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="ItemCode"       HeaderText="S.No / Code"   HeaderStyle-CssClass="left" ItemStyle-CssClass="left" />
                        <asp:BoundField DataField="ItemName"       HeaderText="Ingredient"    HeaderStyle-CssClass="left" ItemStyle-CssClass="left" />
                        <asp:BoundField DataField="Unit"           HeaderText="Unit"          HeaderStyle-CssClass="left" ItemStyle-CssClass="left" />
                        <asp:BoundField DataField="Quantity"       HeaderText="Quantity"      DataFormatString="{0:N3}" />
                        <asp:BoundField DataField="ConversionFactor"         HeaderText="Factor"        DataFormatString="{0:N0}" />
                        <asp:BoundField DataField="LiveRate"       HeaderText="Rate Per Unit" DataFormatString="{0:N2}" />
                        <asp:BoundField DataField="SavedTotalCost" HeaderText="Saved Cost"    DataFormatString="{0:N2}" />
                        <asp:BoundField DataField="LiveTotalCost"  HeaderText="Live Cost"     DataFormatString="{0:N2}" />
                        <asp:TemplateField HeaderText="Variance">
                            <ItemTemplate>
                                <span class='<%# GetVarianceClass(Eval("Variance")) %>'>
                                    <%# FormatVariance(Eval("Variance")) %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <AlternatingRowStyle BackColor="#f6f8fd" />
                </asp:GridView>
            </div>
            <div class="rc-sec-foot" style="border-color:#7a1010;">
                Live Section Total &nbsp; <asp:Label ID="lblTotWastage2" runat="server" />
            </div>
        </asp:Panel>

        <!-- --------------------------
             RECIPE DETAILS  (bottom-left block like the image)
        -------------------------- -->
        <div class="rc-details">
            <div class="rc-details-left">
                <div class="rd-block">
                    <div class="rd-title">Recipe Details</div>
                    <div class="rd-row">
                        <span class="rd-label">Recipe Weight</span>
                        <span class="rd-val"><asp:Label ID="lblWeight2"   runat="server" /></span>
                    </div>
                    <div class="rd-row">
                        <span class="rd-label">Serving Utensil</span>
                        <span class="rd-val"><asp:Label ID="lblUtensil2"  runat="server" /></span>
                    </div>
                    <div class="rd-row">
                        <span class="rd-label">Overhead %</span>
                        <span class="rd-val"><asp:Label ID="lblOverhead"  runat="server" /></span>
                    </div>
                    <div class="rd-row">
                        <span class="rd-label">Inflation %</span>
                        <span class="rd-val"><asp:Label ID="lblInflation" runat="server" /></span>
                    </div>
                    <div class="rd-row">
                        <span class="rd-label">Selling Price</span>
                        <span class="rd-val" style="color:#185FA5;">
                            <asp:Label ID="lblSellPrice2" runat="server" /></span>
                    </div>
                </div>
            </div>
            <div class="rc-details-right">
                <div class="rd-block">
                    <div class="rd-title">Cost Breakdown</div>
                    <div class="rd-row">
                        <span class="rd-label">Saved Recipe Cost</span>
                        <span class="rd-val"><asp:Label ID="lblSavedCost" runat="server" /></span>
                    </div>
                    <div class="rd-row">
                        <span class="rd-label">Live Recipe Cost</span>
                        <span class="rd-val"><asp:Label ID="lblLiveCost" runat="server" /></span>
                    </div>
                    <div class="rd-row">
                        <span class="rd-label">Live Overhead</span>
                        <span class="rd-val"><asp:Label ID="lblLiveOverhead" runat="server" /></span>
                    </div>
                    <div class="rd-row">
                        <span class="rd-label">Live Inflation</span>
                        <span class="rd-val"><asp:Label ID="lblLiveInflation" runat="server" /></span>
                    </div>
                    <div class="rd-row" style="border-bottom:2px solid #1a3a6b;">
                        <span class="rd-label" style="font-weight:700;">
                            Total Cost / Portion (Ingredients + Garnish)</span>
                        <span class="rd-val" style="font-size:13px;color:#1a3a6b;">
                            <asp:Label ID="lblLiveCPP" runat="server" /></span>
                    </div>
                </div>
            </div>
        </div>

        <!-- --------------------------
             SUMMARY METRICS ROW
        -------------------------- -->
        <div class="rc-summary">
            <div class="rc-summary-item m-info">
                <div class="rsi-label">Live Cost / Portion</div>
                <div class="rsi-val"><asp:Label ID="lblLiveCPP2" runat="server" /></div>
                <div class="rsi-sub">Ingredients + OH + Inflation</div>
            </div>
            <asp:Panel ID="pnlVarMetric" runat="server" CssClass="rc-summary-item">
                <div class="rsi-label">Variance vs Saved</div>
                <div class="rsi-val"><asp:Label ID="lblVarAmt" runat="server" /></div>
                <div class="rsi-sub"><asp:Label ID="lblVarPct" runat="server" /></div>
            </asp:Panel>
            <asp:Panel ID="pnlFCMetric" runat="server" CssClass="rc-summary-item">
                <div class="rsi-label">Live Food Cost %</div>
                <div class="rsi-val"><asp:Label ID="lblFoodCost" runat="server" /></div>
                <div class="rsi-sub">vs Selling Price</div>
            </asp:Panel>
            <asp:Panel ID="pnlPMMetric" runat="server" CssClass="rc-summary-item">
                <div class="rsi-label">Live Profit Margin %</div>
                <div class="rsi-val"><asp:Label ID="lblProfitMargin" runat="server" /></div>
                <div class="rsi-sub">After all costs</div>
            </asp:Panel>
        </div>

        <!-- -- Footer bar -- -->
        <div class="rc-footer">
            <span>Live Price Per: <strong><asp:Label ID="lblSellPrice3" runat="server" /></strong></span>
            <span>Recipe Cost Rs: <strong><asp:Label ID="lblLiveCost2" runat="server" /></strong></span>
            <span>Costing as per Done on: <strong><asp:Label ID="lblGenDate2" runat="server" /></strong></span>
        </div>

    </div><!-- /rc-wrap -->
    </asp:Panel><!-- /pnlReport -->

    <!-- Empty State -->
    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="empty-state">
            <div style="font-size:40px;margin-bottom:10px">??</div>
            <div>No recipe found for the given search criteria.</div>
        </div>
    </asp:Panel>

</div><!-- /page -->
</asp:Content>


