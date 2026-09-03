<%@ Page Language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" AutoEventWireup="true"
         CodeFile="DefineFacilityFine.aspx.cs" Inherits="Pages_System_DefineFacilityFine"
         Title="Facilities & Fines - Lahore Gymkhana Library" %>

<asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        .grid-header {
            background-color: #0f1e36;
            color: #ffffff;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 0.5px;
        }
        .grid-row {
            background-color: #ffffff;
            border-bottom: 1px solid #e2e8f0;
            transition: background-color 0.2s ease;
        }
        .grid-row:hover {
            background-color: #f8fafc;
        }
        .grid-alt-row {
            background-color: #f8fafc;
            border-bottom: 1px solid #e2e8f0;
            transition: background-color 0.2s ease;
        }
        .grid-alt-row:hover {
            background-color: #f1f5f9;
        }
        .badge-active {
            background-color: #d1fae5;
            color: #065f46;
            padding: 4px 8px;
            border-radius: 9999px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }
        .badge-inactive {
            background-color: #fee2e2;
            color: #991b1b;
            padding: 4px 8px;
            border-radius: 9999px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }
        
        /* Fixed Column Styles for GridViews to bypass Parser limitations */
        .cell-left {
            padding: 14px 16px !important;
            text-align: left;
        }
        .cell-right {
            padding: 14px 16px !important;
            text-align: right;
        }
        .cell-center {
            padding: 14px 16px !important;
            text-align: center;
        }
        .col-id {
            padding: 14px 16px !important;
            font-size: 14px;
            font-weight: 600;
            width: 60px;
            text-align: left;
        }
        .col-name {
            padding: 14px 16px !important;
            font-size: 14px;
            font-weight: 500;
            color: #0f1e36;
            text-align: left;
        }
        .col-cost {
            padding: 14px 16px !important;
            font-size: 14px;
            text-align: right;
            font-weight: 600;
            color: #475569;
        }
        .col-status {
            padding: 14px 16px !important;
            text-align: center;
            width: 100px;
        }
        .col-actions {
            padding: 14px 16px !important;
            text-align: center;
            width: 100px;
        }
    </style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">

<!-- Header Banner -->
<div style="background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; padding: 20px 28px; border-radius: 8px; margin-bottom: 24px; border-bottom: 3px solid #c5a059; display: flex; justify-content: space-between; align-items: center; width: 100%; box-sizing: border-box;">
    <div style="display: block;">
        <h2 style="margin: 0; font-size: 22px; font-weight: 600;">Define Facilities & Fines</h2>
        <p style="margin: 4px 0 0; opacity: .8; font-size: 13px; font-weight: 300;">Lahore Gymkhana Club - Setup facilities hourly costs and fine types configuration</p>
    </div>
</div>

<!-- Alert Panel -->
<asp:Panel ID="pnlAlert" runat="server" Visible="false" style="width: 100%;">
    <div id="divAlert" runat="server" style="padding: 16px 24px; border-radius: 8px; font-size: 14px; margin-bottom: 24px; border-left: 4px solid transparent; width: 100%; box-sizing: border-box;">
        <asp:Literal ID="litAlertMsg" runat="server" />
    </div>
</asp:Panel>

<!-- Tab container spanning 100% width with clean headers -->
<div style="display: flex; flex-direction: column; width: 100%; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 1px 2px 0 rgba(0,0,0,0.05); overflow: hidden; margin-bottom: 30px; box-sizing: border-box;">
    <div style="display: flex; background-color: #f8fafc; border-bottom: 1px solid #e2e8f0; width: 100%;" id="tabHeaders">
        <button type="button" class="tab-header-btn" style="flex: 1; padding: 18px 12px; text-align: center; background: none; border: none; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #c5a059; border-bottom: 3px solid #c5a059; background-color: #ffffff; cursor: pointer; transition: all 0.25s ease; outline: none;" onclick="switchTab(0)">Facilities Setup</button>
        <button type="button" class="tab-header-btn" style="flex: 1; padding: 18px 12px; text-align: center; background: none; border: none; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; background-color: transparent; cursor: pointer; transition: all 0.25s ease; outline: none;" onclick="switchTab(1)">Fines & Reasons Setup</button>
    </div>

    <div style="padding: 36px; width: 100%; box-sizing: border-box;">
        <!-- Hidden field to persist active tab state across postbacks -->
        <asp:HiddenField ID="hfActiveTab" runat="server" Value="0" />

        <!-- ========================================== -->
        <!-- Tab 0: Facilities Definition & Listing     -->
        <!-- ========================================== -->
        <div id="paneFacility" class="tab-pane" style="display: block; width: 100%;">
            <div style="display: flex; gap: 30px; flex-wrap: wrap; align-items: flex-start; width: 100%;">
                
                <!-- Left Form: Add/Edit Facility -->
                <div style="flex: 1; min-width: 320px; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 28px; box-sizing: border-box;">
                    <h3 style="font-size: 16px; font-weight: 700; color: #0f1e36; margin-bottom: 20px; border-bottom: 1px dashed #e2e8f0; padding-bottom: 10px; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0;">
                        <asp:Literal ID="litFacilityFormTitle" runat="server" Text="Add New Facility" />
                    </h3>
                    
                    <asp:HiddenField ID="hfFacilityID" runat="server" Value="" />
                    
                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Facility Name<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                        <asp:TextBox ID="txtFacilityName" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. Conference Room A" />
                    </div>

                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Cost Per Hour (PKR)<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                        <asp:TextBox ID="txtCostPerHour" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. 150.00" Type="Number" step="0.01" min="0" />
                    </div>

                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 24px; width: 100%; box-sizing: border-box;">
                        <asp:CheckBox ID="chkFacilityActive" runat="server" Checked="true" style="cursor: pointer;" />
                        <label for="<%= chkFacilityActive.ClientID %>" style="font-size: 13px; font-weight: 600; color: #1e293b; cursor: pointer; margin: 0; user-select: none;">Mark this Facility as Active</label>
                    </div>

                    <div style="display: flex; gap: 12px; width: 100%;">
                        <asp:Button ID="btnSaveFacility" runat="server" Text="Save Facility" style="flex: 2; padding: 13px 20px; border: none; border-radius: 8px; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; cursor: pointer; text-align: center; outline: none; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #0f1e36; transition: transform 0.2s;" OnClick="btnSaveFacility_Click" />
                        <asp:Button ID="btnClearFacility" runat="server" Text="Cancel" style="flex: 1; padding: 13px 20px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; text-align: center; outline: none; background-color: #ffffff; color: #64748b; transition: all 0.2s;" OnClick="btnClearFacility_Click" Visible="false" />
                    </div>
                </div>

                <!-- Right Table: Existing Facilities List -->
                <div style="flex: 2; min-width: 450px; box-sizing: border-box;">
                    <h3 style="font-size: 16px; font-weight: 700; color: #0f1e36; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px dashed #e2e8f0; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0;">Defined Facilities</h3>
                    
                    <asp:GridView ID="gvFacilities" runat="server" AutoGenerateColumns="False" style="width: 100%; border-collapse: collapse; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;"
                                  HeaderStyle-CssClass="grid-header" RowStyle-CssClass="grid-row" AlternatingRowStyle-CssClass="grid-alt-row" GridLines="None"
                                  OnRowCommand="gvFacilities_RowCommand" DataKeyNames="FacilityID">
                        <Columns>
                            <asp:BoundField DataField="FacilityID" HeaderText="ID" ItemStyle-CssClass="col-id" HeaderStyle-CssClass="cell-left" />
                            <asp:BoundField DataField="FacilityName" HeaderText="Facility Name" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                            <asp:TemplateField HeaderText="Cost / Hour" HeaderStyle-CssClass="cell-right" ItemStyle-CssClass="col-cost">
                                <ItemTemplate>
                                    Rs. <%# Eval("CostPerHour", "{0:N2}") %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Status" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-status">
                                <ItemTemplate>
                                    <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                                        <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-actions">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditFacility" CommandArgument='<%# Eval("FacilityID") %>' style="font-size: 13px; font-weight: 700; color: #c5a059; text-decoration: none; border: 1px solid #c5a059; padding: 6px 12px; border-radius: 6px; background-color: transparent; transition: all 0.2s;" onmouseover="this.style.backgroundColor='#c5a059'; this.style.color='#0f1e36';" onmouseout="this.style.backgroundColor='transparent'; this.style.color='#c5a059';">Edit</asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div style="padding: 40px; text-align: center; color: #64748b; font-size: 14px;">No facilities defined yet.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

            </div>
        </div>

        <!-- ========================================== -->
        <!-- Tab 1: Fines & Reasons Definition & Listing-->
        <!-- ========================================== -->
        <div id="paneFine" class="tab-pane" style="display: none; width: 100%;">
            <div style="display: flex; gap: 30px; flex-wrap: wrap; align-items: flex-start; width: 100%;">
                
                <!-- Left Form: Add/Edit Fine Reason -->
                <div style="flex: 1; min-width: 320px; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 28px; box-sizing: border-box;">
                    <h3 style="font-size: 16px; font-weight: 700; color: #0f1e36; margin-bottom: 20px; border-bottom: 1px dashed #e2e8f0; padding-bottom: 10px; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0;">
                        <asp:Literal ID="litFineFormTitle" runat="server" Text="Add Fine Type" />
                    </h3>
                    
                    <asp:HiddenField ID="hfReasonID" runat="server" Value="" />
                    
                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Fine Reason/Type<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                        <asp:TextBox ID="txtReasonName" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. Lost Book, Damaged Pages" />
                    </div>

                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 24px; width: 100%; box-sizing: border-box;">
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Default Fine Amount (PKR)<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                        <asp:TextBox ID="txtDefaultAmount" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. 500.00" Type="Number" step="0.01" min="0" />
                    </div>

                    <div style="display: flex; gap: 12px; width: 100%;">
                        <asp:Button ID="btnSaveFineReason" runat="server" Text="Save Fine Type" style="flex: 2; padding: 13px 20px; border: none; border-radius: 8px; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; cursor: pointer; text-align: center; outline: none; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #0f1e36; transition: transform 0.2s;" OnClick="btnSaveFineReason_Click" />
                        <asp:Button ID="btnClearFineReason" runat="server" Text="Cancel" style="flex: 1; padding: 13px 20px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; text-align: center; outline: none; background-color: #ffffff; color: #64748b; transition: all 0.2s;" OnClick="btnClearFineReason_Click" Visible="false" />
                    </div>
                </div>

                <!-- Right Table: Existing Fine Types List -->
                <div style="flex: 2; min-width: 450px; box-sizing: border-box;">
                    <h3 style="font-size: 16px; font-weight: 700; color: #0f1e36; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px dashed #e2e8f0; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0;">Defined Fine Types & Reasons</h3>
                    
                    <asp:GridView ID="gvFineReasons" runat="server" AutoGenerateColumns="False" style="width: 100%; border-collapse: collapse; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;"
                                  HeaderStyle-CssClass="grid-header" RowStyle-CssClass="grid-row" AlternatingRowStyle-CssClass="grid-alt-row" GridLines="None"
                                  OnRowCommand="gvFineReasons_RowCommand" DataKeyNames="ReasonID">
                        <Columns>
                            <asp:BoundField DataField="ReasonID" HeaderText="ID" ItemStyle-CssClass="col-id" HeaderStyle-CssClass="cell-left" />
                            <asp:BoundField DataField="ReasonName" HeaderText="Reason / Fine Type" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                            <asp:TemplateField HeaderText="Default Amount" HeaderStyle-CssClass="cell-right" ItemStyle-CssClass="col-cost">
                                <ItemTemplate>
                                    Rs. <%# Eval("DefaultAmount", "{0:N2}") %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-actions">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditFineReason" CommandArgument='<%# Eval("ReasonID") %>' style="font-size: 13px; font-weight: 700; color: #c5a059; text-decoration: none; border: 1px solid #c5a059; padding: 6px 12px; border-radius: 6px; background-color: transparent; transition: all 0.2s;" onmouseover="this.style.backgroundColor='#c5a059'; this.style.color='#0f1e36';" onmouseout="this.style.backgroundColor='transparent'; this.style.color='#c5a059';">Edit</asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div style="padding: 40px; text-align: center; color: #64748b; font-size: 14px;">No fine types defined yet.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

            </div>
        </div>
    </div>
</div>

<script>
    // Tab switching mechanism (pure text buttons, strict inline CSS updates)
    function switchTab(index) {
        // Toggle Active Headers
        var btns = document.querySelectorAll('.tab-header-btn');
        for (var i = 0; i < btns.length; i++) {
            btns[i].style.color = '#64748b';
            btns[i].style.borderBottomColor = 'transparent';
            btns[i].style.backgroundColor = 'transparent';
        }
        btns[index].style.color = '#c5a059';
        btns[index].style.borderBottomColor = '#c5a059';
        btns[index].style.backgroundColor = '#ffffff';

        // Toggle Active Panes
        var panes = document.querySelectorAll('.tab-pane');
        for (var i = 0; i < panes.length; i++) {
            panes[i].style.display = 'none';
        }
        panes[index].style.display = 'block';

        // Persist tab index to ASP.NET HiddenField across postbacks
        var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
        if (hf) {
            hf.value = index;
        }
    }

    // Restore active tab after ASP.NET postback triggers page reload
    window.onload = function() {
        var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
        if (hf && hf.value) {
            var activeIdx = parseInt(hf.value);
            switchTab(activeIdx);
        }
    };
</script>
</asp:Content>
