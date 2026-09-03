<%@ Page Language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" AutoEventWireup="true"
    CodeFile="MultipleBooksWeedout.aspx.cs" Inherits="GymkhanaLibrary.MultipleBooksWeedout"
    Title="Multiple Books Weeding – Lahore Gymkhana Library" %>

<asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">
    
    <div style="background: linear-gradient(135deg, #0f1e36, #1c3254); color: #ffffff; padding: 20px 28px; border-radius: 8px; margin-bottom: 24px; border-bottom: 3px solid #c5a059; width: 100%; box-sizing: border-box;">
        <h2 style="margin: 0; font-size: 22px; font-weight: 600; font-family: 'Playfair Display', serif;">Multiple Books Weeding</h2>
        <p style="margin: 4px 0 0; opacity: .8; font-size: 13px;">Add multiple books to the list and weed them all out at once. Books with active loans are skipped.</p>
    </div>

    <!-- Alert message panel -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false" style="margin-bottom: 20px; width: 100%;">
        <div style='padding: 16px 24px; border-radius: 8px; font-size: 14px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; border-left: 4px solid; width: 100%; box-sizing: border-box; <%# AlertCssClass == "alert-success" ? "background-color: #d1fae5; color: #065f46; border-left-color: #10b981;" : "background-color: #fee2e2; color: #991b1b; border-left-color: #ef4444;" %>'>
            <asp:Label ID="lblAlert" runat="server" />
        </div>
    </asp:Panel>

    <div style="display: grid; grid-template-columns: 1fr; gap: 24px; width: 100%;">
        
        <!-- CARD: Search Book -->
        <div style="background: #ffffff; border-radius: 12px; border: 1px solid #e2e8f0; padding: 24px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); width: 100%; box-sizing: border-box;">
            <h3 style="font-family: 'Playfair Display', serif; font-size: 18px; color: #0f1e36; margin-top: 0; margin-bottom: 16px;">Search & Add Books to Weeding List</h3>
            
            <!-- Radio Buttons to Choose Mode -->
            <div style="margin-bottom: 20px; display: flex; gap: 24px; border-bottom: 1px solid #f1f5f9; padding-bottom: 16px; flex-wrap: wrap;">
                <asp:RadioButton ID="rdoSearchTitle" runat="server" GroupName="SearchMode" Text="&nbsp;Search Book Title / ISBN / DDC" AutoPostBack="true" Checked="true" OnCheckedChanged="rdoSearchMode_CheckedChanged" style="font-weight: 600; color: #0f1e36; cursor: pointer; display: inline-flex; align-items: center;" />
                <asp:RadioButton ID="rdoAddCopy" runat="server" GroupName="SearchMode" Text="&nbsp;Add Individual Copy Directly by Copy Book No." AutoPostBack="true" OnCheckedChanged="rdoSearchMode_CheckedChanged" style="font-weight: 600; color: #0f1e36; cursor: pointer; display: inline-flex; align-items: center;" />
            </div>

            <!-- Panel 1: Search Book -->
            <asp:Panel ID="pnlSearchTitleBlock" runat="server" Visible="true" style="width: 100%;">
                <div style="display: flex; flex-direction: column; gap: 6px;">
                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Search Book Title / ISBN / DDC</label>
                    <div style="display: flex; gap: 12px; align-items: center; max-width: 600px; width: 100%;">
                        <asp:TextBox ID="txtSearchBook" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Search by Book Title, Subtitle, ISBN, DDC, or Book No..." />
                        <asp:Button ID="btnSearchBook" runat="server" Text="Search Book" style="padding: 10px 20px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block; height: 42px; white-space: nowrap;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnSearchBook_Click" />
                    </div>
                </div>
            </asp:Panel>

            <!-- Panel 2: Add Individual Copy -->
            <asp:Panel ID="pnlAddCopyBlock" runat="server" Visible="false" style="width: 100%;">
                <div style="display: flex; flex-direction: column; gap: 6px;">
                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Add Individual Copy Directly by Copy Book No.</label>
                    <div style="display: flex; gap: 12px; align-items: center; max-width: 600px; width: 100%;">
                        <asp:TextBox ID="txtCopyBookNo" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Enter individual copy Book No..." />
                        <asp:Button ID="btnAddCopy" runat="server" Text="Add Copy" style="padding: 10px 20px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #ab8945 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.1); display: inline-block; height: 42px; white-space: nowrap;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(197, 160, 89, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(197, 160, 89, 0.1)';" OnClick="btnAddCopy_Click" />
                    </div>
                </div>
            </asp:Panel>

            <!-- Search Results -->
            <asp:Panel ID="pnlSearchResults" runat="server" Visible="false" style="width: 100%;">
                <h4 style="font-size: 14px; color: #475569; margin-bottom: 10px;">Matching Books – Click "Add" to include in weeding list:</h4>
                <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                    <asp:GridView ID="gvBooks" runat="server" AutoGenerateColumns="false" GridLines="None"
                        DataKeyNames="BookID" OnRowCommand="gvBooks_RowCommand" AllowPaging="true" PageSize="5"
                        OnPageIndexChanging="gvBooks_PageIndexChanging"
                        style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;">
                        <HeaderStyle CssClass="gv-header" />
                        <RowStyle CssClass="gv-row" />
                        <AlternatingRowStyle CssClass="gv-alt-row" />
                        <PagerStyle CssClass="pager-style"/>
                        <Columns>
                            <asp:TemplateField HeaderText="Book No.">
                                <HeaderStyle CssClass="gv-header-left" Width="90px" />
                                <ItemStyle CssClass="gv-text-left" />
                                <ItemTemplate>
                                    <span style="font-weight: 600; color: #64748b;"><%# Eval("BookID") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="ISBN13" HeaderText="ISBN-13">
                                <HeaderStyle CssClass="gv-header-left" Width="150px" />
                                <ItemStyle CssClass="gv-text-left" />
                            </asp:BoundField>
                            <asp:BoundField DataField="Title" HeaderText="Title">
                                <HeaderStyle CssClass="gv-header-left" />
                                <ItemStyle CssClass="gv-text-left" />
                            </asp:BoundField>
                            <asp:BoundField DataField="CatName" HeaderText="Subject">
                                <HeaderStyle CssClass="gv-header-left" Width="150px" />
                                <ItemStyle CssClass="gv-text-left" />
                            </asp:BoundField>
                            <asp:BoundField DataField="DDC" HeaderText="DDC">
                                <HeaderStyle CssClass="gv-header-left" Width="120px" />
                                <ItemStyle CssClass="gv-text-left" />
                            </asp:BoundField>
                            <asp:BoundField DataField="TotalCopies" HeaderText="Total Copies">
                                <HeaderStyle CssClass="gv-header gv-text-center" Width="100px" />
                                <ItemStyle CssClass="gv-text-center" />
                            </asp:BoundField>
                            <asp:BoundField DataField="AvailableCopies" HeaderText="Available">
                                <HeaderStyle CssClass="gv-header gv-text-center" Width="100px" />
                                <ItemStyle CssClass="gv-text-center" />
                            </asp:BoundField>
                            <asp:TemplateField>
                                <HeaderStyle CssClass="gv-header gv-text-center" Width="120px" />
                                <ItemStyle CssClass="gv-text-center" />
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkAdd" runat="server" CommandName="AddBook" CommandArgument='<%# Eval("BookID") %>' Text="Add to List" style="background-color: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; padding: 6px 12px; border-radius: 8px; font-size: 12px; font-weight: 600; cursor: pointer; transition: all 0.2s ease; display: inline-block; text-decoration: none;" onmouseover="this.style.backgroundColor='#e2e8f0';" onmouseout="this.style.backgroundColor='#f1f5f9';" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </asp:Panel>
        </div>

        <!-- CARD: Selected Books (Weeding List) -->
        <asp:Panel ID="pnlSelectedBooks" runat="server" Visible="false" style="background: #ffffff; border-radius: 12px; border: 1px solid #e2e8f0; padding: 24px; width: 100%; box-sizing: border-box;">
            <h3 style="font-family: 'Playfair Display', serif; font-size: 18px; color: #0f1e36; margin-top: 0; margin-bottom: 16px;">Books Selected for Weeding</h3>
            <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; background-color: #ffffff; margin-bottom: 20px;">
                <asp:GridView ID="gvSelectedBooks" runat="server" AutoGenerateColumns="false" GridLines="None"
                    DataKeyNames="BookID" OnRowCommand="gvSelectedBooks_RowCommand"
                    style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;">
                    <HeaderStyle CssClass="gv-header" />
                    <RowStyle CssClass="gv-row" />
                    <AlternatingRowStyle CssClass="gv-alt-row" />
                    <Columns>
                        <asp:TemplateField HeaderText="Book No.">
                            <HeaderStyle CssClass="gv-header-left" Width="120px" />
                            <ItemStyle CssClass="gv-text-left" />
                            <ItemTemplate>
                                <span style="font-weight: 600; color: #64748b;">
                                    <%# Eval("CopyBookNo") != DBNull.Value ? "Copy " + Eval("CopyBookNo") : "Title " + Eval("BookID") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="ISBN13" HeaderText="ISBN-13">
                            <HeaderStyle CssClass="gv-header-left" Width="150px" />
                            <ItemStyle CssClass="gv-text-left" />
                        </asp:BoundField>
                        <asp:TemplateField HeaderText="Title">
                            <HeaderStyle CssClass="gv-header-left" />
                            <ItemStyle CssClass="gv-text-left" />
                            <ItemTemplate>
                                <span style="font-weight: 600; color: #0f1e36;">
                                    <%# Eval("Title") %>
                                </span>
                                <%# Eval("Barcode") != DBNull.Value && !string.IsNullOrEmpty(Eval("Barcode").ToString()) ? "<div style='font-size: 11px; font-family: monospace; color: #64748b; margin-top: 2px;'>Barcode: " + Eval("Barcode") + "</div>" : "" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="TotalCopies" HeaderText="Total Copies">
                            <HeaderStyle CssClass="gv-header gv-text-center" Width="100px" />
                            <ItemStyle CssClass="gv-text-center" />
                        </asp:BoundField>
                        <asp:BoundField DataField="AvailableCopies" HeaderText="Available">
                            <HeaderStyle CssClass="gv-header gv-text-center" Width="100px" />
                            <ItemStyle CssClass="gv-text-center" />
                        </asp:BoundField>
                        <asp:TemplateField HeaderText="Loan Status">
                            <HeaderStyle CssClass="gv-header-left" Width="150px" />
                            <ItemStyle CssClass="gv-text-left" />
                            <ItemTemplate>
                                <asp:Label ID="lblLoanStatus" runat="server" Text='<%# Eval("LoanStatus") %>'
                                    Style='<%# Eval("CanWeed") != null && (bool)Eval("CanWeed") ? "color:#10b981; font-weight:600;" : "color:#ef4444; font-weight:600;" %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField>
                            <HeaderStyle CssClass="gv-header gv-text-center" Width="80px" />
                            <ItemStyle CssClass="gv-text-center" />
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkRemove" runat="server" CommandName="RemoveBook" CommandArgument='<%# Eval("BookID") %>' Text="Remove" style="color: #ef4444; font-weight: 600; text-decoration: none; cursor: pointer;" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
            <div style="text-align: right;">
                <asp:Button ID="btnWeedAllSelected" runat="server" Text="Weed Out All Selected Books" 
                    style="padding: 10px 20px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: #ef4444; color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(239, 68, 68, 0.2); display: inline-block; height: 42px;" 
                    onmouseover="this.style.backgroundColor='#dc2626'; this.style.transform='translateY(-1px)';" 
                    onmouseout="this.style.backgroundColor='#ef4444'; this.style.transform='none';" 
                    OnClick="btnWeedAllSelected_Click" />
            </div>
        </asp:Panel>
    </div>

</asp:Content>