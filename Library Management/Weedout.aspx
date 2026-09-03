<%@ page language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" autoeventwireup="true" CodeFile="Weedout.aspx.cs" inherits="GymkhanaLibrary.Weedout" title="Book Weeding Management - Lahore Gymkhana Library" %>

<asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">
    
    <div style="background: linear-gradient(135deg, #0f1e36, #1c3254); color: #ffffff; padding: 20px 28px; border-radius: 8px; margin-bottom: 24px; border-bottom: 3px solid #c5a059; width: 100%; box-sizing: border-box;">
        <h2 style="margin: 0; font-size: 22px; font-weight: 600; font-family: 'Playfair Display', serif;">Book Weeding Operations</h2>
        <p style="margin: 4px 0 0; opacity: .8; font-size: 13px;">Mark books & physical copies as weeded out, or restore them back to physical shelves.</p>
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
            <h3 style="font-family: 'Playfair Display', serif; font-size: 18px; color: #0f1e36; margin-top: 0; margin-bottom: 16px;">Search & Select Book</h3>
            <div style="display: flex; gap: 12px; align-items: center; max-width: 600px; margin-bottom: 16px; width: 100%;">
                <asp:TextBox ID="txtSearchBook" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Search by Book Title, Subtitle, ISBN, DDC, or Book No..." />
                <asp:Button ID="btnSearchBook" runat="server" Text="Search Book" style="padding: 10px 20px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block; height: 42px;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnSearchBook_Click" />
            </div>

            <!-- Search Results -->
            <asp:Panel ID="pnlSearchResults" runat="server" Visible="false" style="width: 100%;">
                <h4 style="font-size: 14px; color: #475569; margin-bottom: 10px;">Matching Books:</h4>
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
                                    <asp:LinkButton ID="lnkSelect" runat="server" CommandName="SelectBook" CommandArgument='<%# Eval("BookID") %>' Text="Manage Weeding" style="background-color: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; padding: 6px 12px; border-radius: 8px; font-size: 12px; font-weight: 600; cursor: pointer; transition: all 0.2s ease; display: inline-block; text-decoration: none;" onmouseover="this.style.backgroundColor='#e2e8f0';" onmouseout="this.style.backgroundColor='#f1f5f9';" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </asp:Panel>
        </div>

        <asp:Panel ID="pnlManageWeeding" runat="server" Visible="false" style="width: 100%;">
            
            <!-- Book Details Summary -->
            <div style="background: #ffffff; border-radius: 12px; border: 1px solid #e2e8f0; border-left: 5px solid #c5a059; padding: 24px; margin-bottom: 24px; width: 100%; box-sizing: border-box;">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 16px; width: 100%;">
                    <div>
                        <span style="font-size: 11px; text-transform: uppercase; font-weight: 700; color: #c5a059; letter-spacing: 0.5px;">Selected Book</span>
                        <h2 style="font-family: 'Playfair Display', serif; font-size: 24px; color: #0f1e36; margin: 4px 0 8px 0;"><asp:Label ID="lblBookTitle" runat="server" /></h2>
                        <p style="color: #64748b; font-size: 13px; margin: 0;">
                            <strong>ISBN-13:</strong> <asp:Label ID="lblBookISBN" runat="server" /> &nbsp;|&nbsp; 
                            <strong>Subject:</strong> <asp:Label ID="lblBookCategory" runat="server" /> &nbsp;|&nbsp; 
                            <strong>Edition:</strong> <asp:Label ID="lblBookEdition" runat="server" /> &nbsp;|&nbsp;
                            <strong>Class No:</strong> <asp:Label ID="lblBookClassNo" runat="server" />
                        </p>
                    </div>
                    <div style="text-align: right;">
                        <span style="font-size: 13px; color: #64748b;">Total Copies: <strong><asp:Label ID="lblTotalCopies" runat="server" /></strong></span><br/>
                        <span style="font-size: 13px; color: #10b981;">Available Copies: <strong><asp:Label ID="lblAvailableCopies" runat="server" /></strong></span>
                    </div>
                </div>
            </div>

            <!-- weeding options section -->
            <div style="display: flex; gap: 24px; flex-wrap: wrap; width: 100%; box-sizing: border-box; align-items: start;">
                
                <!-- Left: List of copies & weeding operations -->
                <div style="background: #ffffff; border-radius: 12px; border: 1px solid #e2e8f0; padding: 24px; margin-bottom: 24px; flex: 1; min-width: 500px; box-sizing: border-box;">
                    <h3 style="font-family: 'Playfair Display', serif; font-size: 18px; color: #0f1e36; margin-top: 0; margin-bottom: 16px;">Physical Book Copies</h3>
                    
                    <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                        <asp:GridView ID="gvCopies" runat="server" AutoGenerateColumns="false" GridLines="None"
                            DataKeyNames="CopyID" OnRowCommand="gvCopies_RowCommand"
                            style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;">
                            <HeaderStyle CssClass="gv-header" />
                            <RowStyle CssClass="gv-row" />
                            <AlternatingRowStyle CssClass="gv-alt-row" />
                            <Columns>
                                <asp:TemplateField HeaderText="Book No">
                                    <HeaderStyle CssClass="gv-header-left" Width="100px" />
                                    <ItemStyle CssClass="gv-text-left" />
                                    <ItemTemplate>
                                        <span style="font-weight: 600; color: #64748b;"><%# Eval("BookNo") %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:BoundField DataField="Barcode" HeaderText="Barcode">
                                    <HeaderStyle CssClass="gv-header-left" Width="150px" />
                                    <ItemStyle CssClass="gv-text-left" />
                                </asp:BoundField>
                                
                                <asp:BoundField DataField="CurrentRack" HeaderText="Current Location">
                                    <HeaderStyle CssClass="gv-header-left" />
                                    <ItemStyle CssClass="gv-text-left" />
                                </asp:BoundField>
                                
                                <asp:TemplateField HeaderText="Condition">
                                    <HeaderStyle CssClass="gv-header-left" Width="120px" />
                                    <ItemStyle CssClass="gv-text-left" />
                                    <ItemTemplate>
                                        <span style="display: inline-block; padding: 4px 8px; border-radius: 9999px; font-size: 11px; font-weight: 600; text-transform: uppercase; background-color: #f1f5f9; color: #475569; border: 1px solid #cbd5e1;"><%# Eval("CondName") %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                
                                <asp:TemplateField HeaderText="Status">
                                    <HeaderStyle CssClass="gv-header-left" Width="120px" />
                                    <ItemStyle CssClass="gv-text-left" />
                                    <ItemTemplate>
                                        <span style='display: inline-block; padding: 4px 8px; border-radius: 9999px; font-size: 11px; font-weight: 600; text-transform: uppercase; <%# Convert.ToInt32(Eval("CondID")) == 7 ? "background-color: #fee2e2; color: #991b1b;" : (Convert.ToBoolean(Eval("IsAvailable")) ? "background-color: #d1fae5; color: #065f46;" : "background-color: #fef3c7; color: #92400e;") %>'>
                                            <%# Convert.ToInt32(Eval("CondID")) == 7 ? "Weeded Out" : (Convert.ToBoolean(Eval("IsAvailable")) ? "Available" : "On Loan") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                
                                <asp:TemplateField HeaderText="Actions">
                                    <HeaderStyle CssClass="gv-header-left" Width="200px" />
                                    <ItemStyle CssClass="gv-text-left" />
                                    <ItemTemplate>
                                        <div style="display: flex; gap: 8px;">
                                            <!-- Show Weed option only if copy is not weeded out -->
                                            <asp:LinkButton ID="lnkWeedCopy" runat="server" CommandName="WeedCopy" CommandArgument='<%# Eval("CopyID") %>' 
                                                Visible='<%# Convert.ToInt32(Eval("CondID")) != 7 %>'
                                                style="padding: 6px 12px; border-radius: 8px; border: none; cursor: pointer; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: #ef4444; color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(239, 68, 68, 0.2); display: inline-block; text-decoration: none;"
                                                onmouseover="this.style.backgroundColor='#dc2626'; this.style.transform='translateY(-1px)';" onmouseout="this.style.backgroundColor='#ef4444'; this.style.transform='none';">Weed Out</asp:LinkButton>
                                            
                                            <!-- Show Restore option only if copy IS weeded out -->
                                            <asp:LinkButton ID="lnkRestoreCopy" runat="server" CommandName="RestoreCopy" CommandArgument='<%# Eval("CopyID") %>' 
                                                Visible='<%# Convert.ToInt32(Eval("CondID")) == 7 %>'
                                                style="padding: 6px 12px; border-radius: 8px; border: none; cursor: pointer; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block; text-decoration: none;"
                                                onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(197, 160, 89, 0.3)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(197, 160, 89, 0.2)';">Restore Copy</asp:LinkButton>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>

                    <!-- Weed Out All Copies (Bulk Weeding) -->
                    <div style="margin-top: 32px; padding-top: 20px; border-top: 1px solid #e2e8f0; width: 100%;">
                        <h4 style="font-family: 'Playfair Display', serif; font-size: 16px; color: #991b1b; margin-top: 0; margin-bottom: 8px;">Full Book Weed-Out (Mark All Copies as Weeded Out)</h4>
                        <p style="font-size: 13px; color: #64748b; margin-bottom: 12px;">This will mark all copies of the book as weeded out and clear shelf allocations.</p>
                        
                        <div style="display: flex; flex-direction: column; gap: 8px; max-width: 500px; width: 100%;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 2px;">Bulk Weed Remarks *</label>
                            <asp:TextBox ID="txtBulkRemarks" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Enter remarks (e.g. Outdated syllabus, physical wear etc.)" />
                            <div style="margin-top: 8px;">
                                <asp:Button ID="btnBulkWeed" runat="server" Text="Weed Out All Copies" style="padding: 10px 20px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: #ef4444; color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(239, 68, 68, 0.2); display: inline-block; height: 42px;" onmouseover="this.style.backgroundColor='#dc2626'; this.style.transform='translateY(-1px)';" onmouseout="this.style.backgroundColor='#ef4444'; this.style.transform='none';" OnClick="btnBulkWeed_Click" 
                                    OnClientClick="return confirm('Are you sure you want to weed out all copies of this book? This cannot be undone.');" />
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right: Action Panel (Individual Weed/Restore Popup form) -->
                <div style="width: 380px; box-sizing: border-box;">
                    <!-- PANEL: Individual Copy Weeding -->
                    <asp:Panel ID="pnlWeedIndividual" runat="server" Visible="false" style="background: #ffffff; border-radius: 12px; border: 2px solid #ef4444; padding: 24px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); width: 100%; box-sizing: border-box;">
                        <h3 style="font-family: 'Playfair Display', serif; font-size: 18px; color: #ef4444; margin-top: 0; margin-bottom: 16px;">Weed Out Copy</h3>
                        
                        <asp:HiddenField ID="hfWeedCopyID" runat="server" />
                        
                        <div style="margin-bottom: 12px;">
                            <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 4px; display: block;">Copy Barcode</span>
                            <span style="font-family: monospace; font-size: 16px; font-weight: 700; color: #1e293b;"><asp:Label ID="lblWeedBarcode" runat="server" /></span>
                        </div>

                        <div style="margin-bottom: 16px;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Weeding Remarks / Reason *</label>
                            <asp:TextBox ID="txtWeedRemarks" runat="server" TextMode="MultiLine" Rows="3" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="e.g. Severely torn, water damage, missing pages..." />
                        </div>

                        <div style="display: flex; gap: 8px; width: 100%;">
                            <asp:Button ID="btnConfirmWeed" runat="server" Text="Confirm Weed" style="flex: 1; padding: 10px 16px; border-radius: 8px; border: none; cursor: pointer; font-size: 12.5px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: #ef4444; color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(239, 68, 68, 0.2); text-align: center; height: 42px;" onmouseover="this.style.backgroundColor='#dc2626'; this.style.transform='translateY(-1px)';" onmouseout="this.style.backgroundColor='#ef4444'; this.style.transform='none';" OnClick="btnConfirmWeed_Click" />
                            <asp:Button ID="btnCancelWeed" runat="server" Text="Cancel" style="padding: 10px 16px; border-radius: 8px; border: 1px solid #cbd5e1; cursor: pointer; font-size: 12.5px; font-weight: 600; background-color: #ffffff; color: #64748b; transition: all 0.2s ease; text-align: center; height: 42px;" onmouseover="this.style.backgroundColor='#f1f5f9'; this.style.color='#1e293b';" onmouseout="this.style.backgroundColor='#ffffff'; this.style.color='#64748b';" OnClick="btnCancelAction_Click" />
                        </div>
                    </asp:Panel>

                    <!-- PANEL: Restore Copy -->
                    <asp:Panel ID="pnlRestoreCopy" runat="server" Visible="false" style="background: #ffffff; border-radius: 12px; border: 2px solid #10b981; padding: 24px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); width: 100%; box-sizing: border-box;">
                        <h3 style="font-family: 'Playfair Display', serif; font-size: 18px; color: #10b981; margin-top: 0; margin-bottom: 16px;">Restore & Re-issue Copy</h3>
                        
                        <asp:HiddenField ID="hfRestoreCopyID" runat="server" />
                        
                        <div style="margin-bottom: 12px;">
                            <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 4px; display: block;">Copy Barcode</span>
                            <span style="font-family: monospace; font-size: 16px; font-weight: 700; color: #1e293b;"><asp:Label ID="lblRestoreBarcode" runat="server" /></span>
                        </div>

                        <div style="margin-bottom: 12px; width: 100%;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Copy Condition *</label>
                            <asp:DropDownList ID="ddlRestoreCondition" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';">
                                <asp:ListItem Value="1">New</asp:ListItem>
                                <asp:ListItem Value="2" Selected="True">Good</asp:ListItem>
                                <asp:ListItem Value="3">Fair</asp:ListItem>
                                <asp:ListItem Value="4">Worn</asp:ListItem>
                                <asp:ListItem Value="5">Damaged</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <!-- Shelf allocation -->
                        <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 14px; margin-bottom: 16px; width: 100%; box-sizing: border-box;">
                            <span style="font-size: 11px; font-weight: 700; color: #0f1e36; text-transform: uppercase; margin-bottom: 10px; display: block; letter-spacing: 0.5px;">Allocate Physical Location</span>
                            
                            <div style="margin-bottom: 8px; width: 100%;">
                                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 4px; display: block;">Library Hall *</label>
                                <asp:DropDownList ID="ddlHall" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" AutoPostBack="true" OnSelectedIndexChanged="ddlHall_SelectedIndexChanged" />
                            </div>
                            
                            <div style="margin-bottom: 8px; width: 100%;">
                                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 4px; display: block;">Aisle *</label>
                                <asp:DropDownList ID="ddlAisle" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" AutoPostBack="true" OnSelectedIndexChanged="ddlAisle_SelectedIndexChanged" Enabled="false" />
                            </div>
                            
                            <div style="margin-bottom: 8px; width: 100%;">
                                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 4px; display: block;">Shelf Unit *</label>
                                <asp:DropDownList ID="ddlShelfUnit" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" AutoPostBack="true" OnSelectedIndexChanged="ddlShelfUnit_SelectedIndexChanged" Enabled="false" />
                            </div>
                            
                            <div style="margin-bottom: 8px; width: 100%;">
                                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 4px; display: block;">Rack *</label>
                                <asp:DropDownList ID="ddlRack" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" AutoPostBack="true" OnSelectedIndexChanged="ddlRack_SelectedIndexChanged" Enabled="false" />
                            </div>
                            
                            <div style="margin-bottom: 8px; width: 100%;">
                                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 4px; display: block;">Slot Number *</label>
                                <asp:DropDownList ID="ddlSlot" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" Enabled="false" />
                            </div>
                        </div>

                        <div style="margin-bottom: 16px; width: 100%;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Restoration Remarks *</label>
                            <asp:TextBox ID="txtRestoreRemarks" runat="server" TextMode="MultiLine" Rows="2" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Remarks about restoration..." />
                        </div>

                        <div style="display: flex; gap: 8px; width: 100%;">
                            <asp:Button ID="btnConfirmRestore" runat="server" Text="Restore Copy" style="flex: 1; padding: 10px 16px; border-radius: 8px; border: none; cursor: pointer; font-size: 12.5px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 4px 10px rgba(16, 185, 129, 0.25); text-align: center; height: 42px;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 6px 14px rgba(16, 185, 129, 0.35)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 4px 10px rgba(16, 185, 129, 0.25)';" OnClick="btnConfirmRestore_Click" />
                            <asp:Button ID="btnCancelRestore" runat="server" Text="Cancel" style="padding: 10px 16px; border-radius: 8px; border: 1px solid #cbd5e1; cursor: pointer; font-size: 12.5px; font-weight: 600; background-color: #ffffff; color: #64748b; transition: all 0.2s ease; text-align: center; height: 42px;" onmouseover="this.style.backgroundColor='#f1f5f9'; this.style.color='#1e293b';" onmouseout="this.style.backgroundColor='#ffffff'; this.style.color='#64748b';" OnClick="btnCancelAction_Click" />
                        </div>
                    </asp:Panel>
                </div>

            </div>

        </asp:Panel>

    </div>

</asp:Content>
