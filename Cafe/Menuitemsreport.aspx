<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Menuitemsreport.aspx.cs" Inherits="Menuitemsreport" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Menu Items Report | Lahore Gymkhana</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: Arial, sans-serif;
            font-size: 12px;
            background: #f5f5f5;
            color: #000;
        }

        /* Search Panel */
        .search-panel {
            background: #fff;
            border: 1px solid #ccc;
            padding: 14px 20px;
            margin: 16px auto;
            max-width: 1200px;
            border-radius: 4px;
        }
        .search-panel h3 {
            font-size: 13px;
            margin-bottom: 10px;
            color: #333;
        }
        .search-row {
            display: flex;
            gap: 12px;
            align-items: flex-end;
            flex-wrap: wrap;
        }
        .search-row .field {
            display: flex;
            flex-direction: column;
            gap: 3px;
        }
        .search-row label {
            font-size: 11px;
            color: #555;
        }
        .search-row input[type=text] {
            border: 1px solid #aaa;
            padding: 4px 7px;
            font-size: 12px;
            width: 160px;
        }
        .btn-search {
            background: #003366;
            color: #fff;
            border: none;
            padding: 5px 16px;
            font-size: 12px;
            cursor: pointer;
        }
        .btn-search:hover { background: #004488; }

        /* Report Container */
        .report-wrap {
            max-width: 1200px;
            margin: 0 auto 30px;
            background: #fff;
            border: 1px solid #ccc;
            padding: 24px 28px;
        }

        /* Header */
        .rpt-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 2px solid #000;
            padding-bottom: 8px;
            margin-bottom: 14px;
        }
        .rpt-header .org-name {
            font-size: 18px;
            font-weight: bold;
            letter-spacing: 0.5px;
        }
        .rpt-header .rpt-title {
            font-size: 12px;
            font-weight: bold;
        }
        .rpt-header .logo {
            width: 60px;
            height: 60px;
            border: 2px solid #800000;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 10px;
            color: #800000;
            font-weight: bold;
        }

        /* Info rows */
        .info-row {
            display: flex;
            align-items: baseline;
            margin-bottom: 5px;
        }
        .info-row .lbl {
            width: 130px;
            text-align: right;
            color: #555;
            font-size: 11px;
            padding-right: 8px;
        }
        .info-row .val {
            border-bottom: 1px solid #999;
            min-width: 280px;
            padding: 1px 4px;
            font-weight: bold;
            font-size: 12px;
        }

        /* Section Headers */
        .section-title {
            font-size: 11px;
            font-weight: bold;
            color: #333;
            letter-spacing: 0.8px;
            text-transform: uppercase;
            border-bottom: 1px solid #ccc;
            padding-bottom: 2px;
            margin: 14px 0 8px;
        }

        /* Classification Grid */
        .classif-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 4px 20px;
            margin-bottom: 4px;
        }
        .classif-grid .cf {
            display: flex;
            align-items: baseline;
        }
        .classif-grid .cf .lbl {
            width: 100px;
            text-align: right;
            color: #555;
            font-size: 11px;
            padding-right: 6px;
            white-space: nowrap;
        }
        .classif-grid .cf .val {
            border-bottom: 1px solid #aaa;
            flex: 1;
            padding: 1px 4px;
            font-size: 12px;
        }

        /* Cost row */
        .cost-row {
            display: flex;
            align-items: baseline;
            gap: 12px;
            margin-top: 4px;
        }
        .cost-row .cf {
            display: flex;
            align-items: baseline;
        }
        .cost-row .lbl {
            width: 90px;
            text-align: right;
            color: #555;
            font-size: 11px;
            padding-right: 6px;
        }
        .cost-row .val {
            border-bottom: 1px solid #aaa;
            min-width: 70px;
            padding: 1px 4px;
            font-size: 12px;
            text-align: right;
        }

        /* Outlet Price Table */
        .outlet-section-wrapper {
            width: 100%;
            display: flex;
            justify-content: center;
            margin-top: 6px;
        }
        .outlet-table-wrapper {
            width: 95%;
        }
        
        .outlet-grid {
            width: 100%;
            border-collapse: collapse;
            font-size: 12px;
            font-family: Arial, sans-serif;
        }
        
        .outlet-grid th {
            background-color: #f0f0f0;
            border-bottom: 2px solid #333;
            padding: 8px 6px;
            text-align: left;
            font-weight: bold;
        }
        
        .outlet-grid td {
            border-bottom: 1px solid #ddd;
            padding: 6px;
            vertical-align: top;
        }
        
        .outlet-grid th:nth-child(1), 
        .outlet-grid td:nth-child(1) {
            text-align: left;
            width: 80px;
        }
        
        .outlet-grid th:nth-child(2), 
        .outlet-grid td:nth-child(2) {
            text-align: left;
            width: auto;
        }
        
        .outlet-grid th:nth-child(3), 
        .outlet-grid td:nth-child(3) {
            text-align: right;
            width: 100px;
            padding-right: 15px;
        }
        
        .outlet-grid th:nth-child(4), 
        .outlet-grid td:nth-child(4) {
            text-align: right;
            width: 100px;
            padding-right: 15px;
        }
        
        .price-value {
            color: #000080;
            font-weight: bold;
            text-align: right;
        }

        /* Recipe Grid Styles */
        .recipe-grid {
            width: 100%;
            border-collapse: collapse;
            font-size: 11px;
            margin-top: 10px;
        }

        .recipe-grid th {
            background-color: #f0f0f0;
            padding: 8px;
            text-align: left;
            border-bottom: 2px solid #333;
            font-weight: bold;
            font-size: 11px;
        }

        .recipe-grid td {
            padding: 6px;
            border-bottom: 1px solid #ddd;
        }

        .recipe-grid tr:hover {
            background-color: #f5f5f5;
        }

        .recipe-summary {
            margin-top: 15px;
            padding: 10px;
            background-color: #f9f9f9;
            border: 1px solid #ddd;
            border-radius: 4px;
        }

        .recipe-summary strong {
            color: #800000;
        }

        /* Print button */
        .print-bar {
            max-width: 1200px;
            margin: 0 auto 10px;
            text-align: right;
        }
        .btn-print {
            background: #800000;
            color: #fff;
            border: none;
            padding: 6px 20px;
            font-size: 12px;
            cursor: pointer;
        }
        .btn-print:hover { background: #a00000; }

        /* No Data */
        .no-data {
            text-align: center;
            padding: 30px;
            color: #999;
            font-size: 13px;
        }

        /* Print CSS */
        @media print {
            body { background: #fff; }
            .search-panel, .print-bar, .btn-print { display: none !important; }
            .report-wrap { border: none; margin: 0; padding: 10px; }
            .outlet-grid th, .recipe-grid th {
                background-color: #fff !important;
            }
        }
    </style>
</head>
<body>

    <form id="form1" runat="server">

        <!-- Search Panel -->
        <div class="search-panel">
            <h3>Search Menu Item</h3>
            <div class="search-row">
                <div class="field">
                    <label>Menu Item ID</label>
                    <asp:TextBox ID="txtItemID" runat="server" />
                </div>
                <div class="field">
                    <label>Item Name</label>
                    <asp:TextBox ID="txtItemName" runat="server" />
                </div>
                <asp:HiddenField ID="hfDepartmentID" runat="server" />
                <asp:HiddenField ID="hfDeptName" runat="server" />

                <asp:Button ID="btnSearch" runat="server" Text="Search"
                    CssClass="btn-search" OnClick="btnSearch_Click" />
            </div>
        </div>

        <!-- Print Button -->
        <div class="print-bar">
            <asp:Button ID="btnPrint" runat="server" Text="🖨 Print Report"
                CssClass="btn-print" OnClientClick="window.print(); return false;"
                Visible="false" />
        </div>

        <!-- Report Panel -->
        <asp:Panel ID="pnlReport" runat="server" Visible="false">
            <div class="report-wrap" id="reportArea">

                <!-- Header -->
                <div class="rpt-header">
                    <div>
                        <div class="org-name">LAHORE GYMKHANA</div>
                        <div class="rpt-title">Menu Item Details</div>
                    </div>
                    <div class="logo">LG</div>
                </div>

                <!-- Menu Item ID / Name -->
                <div class="info-row">
                    <span class="lbl">Menu Item ID / Name :</span>
                    <span class="val">
                        <asp:Label ID="lblItemID" runat="server" />&nbsp;&nbsp;
                        <asp:Label ID="lblItemName" runat="server" />
                    </span>
                </div>

                <!-- Print As -->
                <div class="info-row">
                    <span class="lbl">Print As :</span>
                    <span class="val"><asp:Label ID="lblPrintAs" runat="server" /></span>
                </div>

                <!-- Classification Section -->
                <div class="section-title">Classification</div>

                <div class="classif-grid">
                    <div class="cf">
                        <span class="lbl">Sub Menu :</span>
                        <span class="val"><asp:Label ID="lblSubMenu" runat="server" /></span>
                    </div>
                    <div class="cf"></div>

                    <div class="cf">
                        <span class="lbl">Meal Type :</span>
                        <span class="val"><asp:Label ID="lblMealType" runat="server" /></span>
                    </div>
                    <div class="cf">
                        <span class="lbl">Course :</span>
                        <span class="val"><asp:Label ID="lblCourse" runat="server" /></span>
                    </div>

                    <div class="cf">
                        <span class="lbl">Item Printer :</span>
                        <span class="val">&nbsp;</span>
                    </div>
                    <div class="cf">
                        <span class="lbl">Active :</span>
                        <span class="val"><asp:Label ID="lblActive" runat="server" /></span>
                    </div>

                    <div class="cf">
                        <span class="lbl">GST :</span>
                        <span class="val"><asp:Label ID="lblGST" runat="server" /></span>
                    </div>
                    <div class="cf">
                        <span class="lbl">Cost Date :</span>
                        <span class="val">&nbsp;</span>
                    </div>
                </div>

                <!-- Recipe Cost / Add On / Total Cost row -->
                <div class="cost-row">
                    <div class="cf">
                        <span class="lbl">Recipe Cost :</span>
                        <span class="val"><asp:Label ID="lblRecipeCost" runat="server" /></span>
                    </div>
                    <div class="cf">
                        <span class="lbl" style="width:80px">Add On (Rs.) :</span>
                        <span class="val"><asp:Label ID="lblAddOn" runat="server" /></span>
                    </div>
                    <div class="cf">
                        <span class="lbl" style="width:75px">Total Cost :</span>
                        <span class="val" style="min-width:80px"><asp:Label ID="lblTotalCost" runat="server" /></span>
                    </div>
                </div>

                <!-- Outlet Item Price Section -->
                <div class="section-title">Outlet Item Price</div>
                <div class="outlet-section-wrapper">
                    <div class="outlet-table-wrapper">
                        <asp:GridView ID="gvOutlets" runat="server"
                            CssClass="outlet-grid"
                            AutoGenerateColumns="false"
                            GridLines="None"
                            ShowHeader="true"
                            BorderWidth="0"
                            CellPadding="0"
                            CellSpacing="0">
                            <Columns>
                                <asp:TemplateField HeaderText="Outlet">
                                    <ItemTemplate>
                                        <asp:Label ID="lblOutlet" runat="server" Text='<%# Eval("OutletCode") %>' />
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" Width="80px" />
                                    <HeaderStyle HorizontalAlign="Left" Width="80px" />
                                </asp:TemplateField>
                                
                                <asp:TemplateField HeaderText="Name">
                                    <ItemTemplate>
                                        <asp:Label ID="lblName" runat="server" Text='<%# Eval("SubDeptName") %>' />
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" />
                                    <HeaderStyle HorizontalAlign="Left" />
                                </asp:TemplateField>
                                
                                <asp:TemplateField HeaderText="Price">
                                    <ItemTemplate>
                                        <asp:Label ID="lblPrice" runat="server" 
                                            Text='<%# Eval("Price", "{0:N0}") %>'
                                            CssClass="price-value" />
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Right" Width="100px" CssClass="price-value" />
                                    <HeaderStyle HorizontalAlign="Right" Width="100px" />
                                </asp:TemplateField>
                                
                                <asp:TemplateField HeaderText="Old Price">
                                    <ItemTemplate>
                                        <asp:Label ID="lblOldPrice" runat="server" 
                                            Text='<%# Eval("Cost", "{0:N0}") %>'
                                            CssClass="price-value" />
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Right" Width="100px" CssClass="price-value" />
                                    <HeaderStyle HorizontalAlign="Right" Width="100px" />
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="no-data">No outlet prices found.</div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>

                <!-- Recipe Details Section -->
                <div class="section-title">Recipe Details</div>
                <asp:Literal ID="litRecipeDetails" runat="server" />

            </div>
        </asp:Panel>

        <!-- No result message -->
        <asp:Label ID="lblNoResult" runat="server" Visible="false"
            Style="display:block;text-align:center;padding:30px;color:red;font-size:13px" />

    </form>
</body>
</html>