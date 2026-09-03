<%@ Page Language="C#" AutoEventWireup="true"
    CodeFile="ConsumptionValidations.aspx.cs"
    Inherits="ConsumptionValidation" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<title>Consumption Verification – Lahore Gymkhana</title>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700;800;900&family=Geist+Mono:wght@400;500;600&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
<style>
:root{
    --ink:#0A0F1E;
    --blue:#1845D4;--blue-light:#EEF3FF;--blue-dark:#0F2D8A;--blue-mid:#4070F4;
    --surface:#F4F6FB;--line:#DDE3EF;--line-mid:#C8D0E0;--muted:#7A85A0;
    --green:#0E9E52;--green-light:#EDFAF4;--green-dark:#075C30;
    --amber:#D4820A;--amber-light:#FFF8ED;
    --red:#D42B2B;--red-light:#FFF0F0;
    --purple:#6B35D4;--purple-light:#F3EEFF;
    --teal:#0A9E8E;--teal-light:#EDFAF8;
    --sh1:0 1px 3px rgba(10,15,30,.07),0 1px 2px rgba(10,15,30,.05);
    --sh2:0 4px 12px rgba(10,15,30,.08);
    --r:10px;--r-sm:7px;--r-lg:14px;
}
*{margin:0;padding:0;box-sizing:border-box;}
body{font-family:'Geist',system-ui,sans-serif;background:var(--surface);color:var(--ink);font-size:13.5px;line-height:1.5;}
::-webkit-scrollbar{width:5px;height:5px;}
::-webkit-scrollbar-thumb{background:var(--line-mid);border-radius:5px;}

.pg{max-width:1700px;margin:0 auto;padding:18px 20px;}

.page-hdr{display:flex;align-items:center;justify-content:space-between;background:var(--ink);padding:0 22px;height:56px;border-radius:var(--r-lg);margin-bottom:18px;box-shadow:0 4px 18px rgba(10,15,30,.2);}
.page-hdr-brand{display:flex;align-items:center;gap:10px;}
.phdr-icon{width:34px;height:34px;background:linear-gradient(135deg,var(--purple),var(--blue-mid));border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:15px;color:white;}
.phdr-name{color:white;font-size:.9rem;font-weight:800;letter-spacing:-.3px;}
.phdr-sub{color:rgba(255,255,255,.38);font-size:.62rem;letter-spacing:.8px;text-transform:uppercase;}

/* CARDS */
.card{background:white;border-radius:var(--r-lg);box-shadow:var(--sh1);border:1px solid var(--line);margin-bottom:16px;overflow:hidden;}
.card-head{background:linear-gradient(to right,#F7F9FF,white);padding:11px 18px;border-bottom:1px solid var(--line);display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px;}
.card-head h3{font-size:.88rem;font-weight:800;color:var(--ink);display:flex;align-items:center;gap:7px;margin:0;}
.card-head h3 i{color:var(--purple);font-size:13px;}
.card-body{padding:16px 18px;}

/* SUMMARY BAR */
.summary-bar{display:grid;grid-template-columns:repeat(6,1fr);gap:10px;margin-bottom:16px;}
.sb-tile{background:white;border-radius:var(--r);padding:12px 14px;border:1px solid var(--line);}
.sb-tile-lbl{font-size:.58rem;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.6px;margin-bottom:3px;}
.sb-tile-val{font-family:'Geist Mono',monospace;font-size:.95rem;font-weight:800;}
.stv-blue{color:var(--blue);}
.stv-green{color:var(--green-dark);}
.stv-red{color:var(--red);}
.stv-amber{color:var(--amber);}
.stv-purple{color:var(--purple);}

/* BUTTONS */
.wbtn{display:inline-flex;align-items:center;justify-content:center;gap:6px;height:38px;padding:0 16px;border:none;border-radius:var(--r-sm);font-size:12px;font-weight:700;font-family:'Geist',sans-serif;cursor:pointer;transition:all .2s;white-space:nowrap;}
.wbtn-primary{background:var(--blue);color:white;}
.wbtn-primary:hover{background:var(--blue-dark);transform:translateY(-1px);}
.wbtn-success{background:linear-gradient(135deg,var(--green-dark),var(--green));color:white;}
.wbtn-success:hover{transform:translateY(-1px);}
.wbtn-danger{background:var(--red);color:white;}
.wbtn-danger:hover{background:#b91c1c;transform:translateY(-1px);}
.wbtn-warning{background:var(--amber);color:white;}
.wbtn-warning:hover{transform:translateY(-1px);}
.wbtn-secondary{background:white;color:var(--muted);border:1.5px solid var(--line);}
.wbtn-secondary:hover{background:var(--blue-light);border-color:var(--blue);color:var(--blue);}
.wbtn-sm{height:30px;padding:0 12px;font-size:11px;}

/* INPUTS */
.v-input{height:30px;border:1.5px solid var(--line);border-radius:var(--r-sm);padding:0 8px;font-size:12px;font-family:'Geist Mono',monospace;color:var(--ink);background:white;transition:all .2s;}
.v-input:focus{outline:none;border-color:var(--purple);box-shadow:0 0 0 2px rgba(107,53,212,.1);}
.v-input.approved{border-color:var(--green);background:#F0FDF4;}
.v-select{height:30px;border:1.5px solid var(--line);border-radius:var(--r-sm);padding:0 8px;font-size:11.5px;background:white;color:var(--ink);cursor:pointer;min-width:130px;}
.v-select:focus{outline:none;border-color:var(--purple);}
.v-select.decision-approved   {border-color:var(--green); background:#F0FDF4;}
.v-select.decision-adjusted   {border-color:var(--amber); background:#FFFBEB;}
.v-select.decision-rejected   {border-color:var(--red);   background:#FFF0F0;}
.v-select.decision-substitute {border-color:var(--purple);background:var(--purple-light);}
.v-select.decision-emergency  {border-color:var(--amber); background:#FFFBEB;}

/* TABLE */
.table-outer{overflow-x:auto;border-radius:var(--r-sm);border:1px solid var(--line);}
.table-outer::-webkit-scrollbar{height:5px;}
.cc-table{width:100%;border-collapse:collapse;font-size:12px;}
.cc-table thead tr{background:linear-gradient(to right,#EEF0FF,#F7F9FF);}
.cc-table th{padding:10px 11px;font-size:.6rem;font-weight:800;color:#475569;text-transform:uppercase;letter-spacing:.7px;border-bottom:2px solid var(--line);white-space:nowrap;position:sticky;top:0;background:linear-gradient(to right,#EEF0FF,#F7F9FF);z-index:2;}
.cc-table td{padding:8px 11px;border-bottom:1px solid #F0F4FA;vertical-align:middle;}
.cc-table tbody tr:hover td{background:#F7F9FF;}
.cc-table .mono{font-family:'Geist Mono',monospace;font-weight:600;font-size:11.5px;}

/* ZERO STOCK ROW */
.cc-table tbody tr.zs-row td{background:#FFF5F5 !important;border-left:3px solid var(--red);}
.cc-table tbody tr.zs-row:hover td{background:#FFE8E8 !important;}

/* INSUFFICIENT STOCK ROW */
.cc-table tbody tr.ls-row td{background:#FFFBEB !important;border-left:3px solid var(--amber);}

/* DIFF BADGES */
.diff-pos {color:var(--green-dark);background:var(--green-light);padding:2px 7px;border-radius:20px;font-weight:700;font-family:'Geist Mono',monospace;font-size:11px;display:inline-block;}
.diff-neg {color:var(--red);background:var(--red-light);padding:2px 7px;border-radius:20px;font-weight:700;font-family:'Geist Mono',monospace;font-size:11px;display:inline-block;}
.diff-zero{color:var(--muted);background:var(--surface);padding:2px 7px;border-radius:20px;font-weight:500;font-family:'Geist Mono',monospace;font-size:11px;display:inline-block;}

/* STOCK BADGES */
.stk-ok    {color:var(--green-dark);font-weight:700;font-size:11px;}
.stk-low   {color:var(--amber);font-weight:700;font-size:11px;}
.stk-zero  {color:var(--red);font-weight:800;font-size:11px;animation:blink .8s step-end infinite;}
@keyframes blink{50%{opacity:.4;}}

/* BADGE */
.badge{display:inline-flex;align-items:center;gap:4px;padding:2px 8px;border-radius:100px;font-size:10px;font-weight:700;}
.bp-sub  {background:var(--amber-light);color:#92400E;border:1px solid #FDE68A;}
.bp-emerg{background:var(--red-light);color:var(--red);border:1px solid #FECACA;}

/* ALERT */
.alert-box{border-radius:var(--r);padding:12px 16px;margin-bottom:14px;display:flex;align-items:center;gap:12px;}
.alert-success{background:var(--green-light);border:2px solid #BBF7D0;color:var(--green-dark);}
.alert-error  {background:var(--red-light);border:2px solid #FECACA;color:var(--red);}
.alert-warning{background:var(--amber-light);border:2px solid #FDE68A;color:var(--amber);}
.alert-info   {background:var(--blue-light);border:2px solid #BFDBFE;color:var(--blue);}
.alert-box .atxt{font-weight:600;font-size:.85rem;}

/* REJECT MODAL AREA */
.reject-area{background:#FFF5F5;border:2px solid var(--red);border-radius:var(--r);padding:14px 18px;margin-bottom:14px;}
.reject-area-title{font-weight:800;color:var(--red);font-size:.84rem;margin-bottom:8px;}
.reject-textarea{width:100%;height:80px;border:1.5px solid #FECACA;border-radius:var(--r-sm);padding:8px 12px;font-size:12.5px;font-family:'Geist',sans-serif;resize:vertical;}
.reject-textarea:focus{outline:none;border-color:var(--red);}

/* EMPTY STATE */
.empty-state{text-align:center;padding:48px 20px;background:linear-gradient(135deg,#F7F9FF,#F1F5FF);border-radius:var(--r);border:2px dashed #C0CFFF;margin:16px;}
.empty-state i{font-size:38px;color:#C0CFFF;margin-bottom:10px;display:block;}
.empty-state h4{color:var(--blue);margin-bottom:5px;font-size:.95rem;font-weight:800;}
.empty-state p{color:var(--muted);font-size:.82rem;}

/* POSTED OVERLAY */
.posted-banner{background:var(--green-light);border:2px solid #BBF7D0;border-radius:var(--r);padding:14px 18px;margin-bottom:14px;display:flex;align-items:center;gap:12px;}
.posted-banner i{color:var(--green-dark);font-size:22px;}
.posted-title{font-weight:800;color:var(--green-dark);font-size:.9rem;}
.posted-sub{font-size:.76rem;color:var(--green-dark);margin-top:2px;opacity:.8;}

@media(max-width:1100px){.summary-bar{grid-template-columns:repeat(3,1fr);}}
@media(max-width:700px){.summary-bar{grid-template-columns:1fr 1fr;}.pg{padding:14px;}}
</style>
</head>
<body>
<form id="form1" runat="server">
<div class="pg">

    <!-- PAGE HEADER -->
    <div class="page-hdr">
        <div class="page-hdr-brand">
            <div class="phdr-icon"><i class="fas fa-clipboard-check"></i></div>
            <div>
                <div class="phdr-name">Consumption Verification</div>
                <div class="phdr-sub">Verify chef entries · Approve / Reject / Adjust · Post to Store</div>
            </div>
        </div>
        <a href="SearchCounter.aspx" style="color:rgba(255,255,255,.6);font-size:.75rem;text-decoration:none;">
            <i class="fas fa-arrow-left"></i> Back to Control Panel
        </a>
    </div>

    <!-- HIDDEN FIELDS -->
    <asp:HiddenField ID="hdnMasterId"  runat="server" Value="0"/>
    <asp:HiddenField ID="hdnCCID"      runat="server" Value="0"/>
    <asp:HiddenField ID="hdnDeptId"    runat="server" Value=""/>
    <asp:HiddenField ID="hdnIsPosted"  runat="server" Value="0"/>

    <!-- ALERT -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <div id="divAlert" runat="server" class="alert-box">
            <i class="fas fa-info-circle"></i>
            <div class="atxt"><asp:Label ID="lblAlert" runat="server"/></div>
        </div>
    </asp:Panel>

    <!-- POSTED BANNER -->
    <asp:Panel ID="pnlPostedBanner" runat="server" Visible="false">
        <div class="posted-banner">
            <i class="fas fa-check-circle"></i>
            <div>
                <div class="posted-title">Posted to Store — Read Only</div>
                <div class="posted-sub">
                    Posted by: <asp:Label ID="lblPostedBy" runat="server"/>
                    &nbsp;|&nbsp; Date: <asp:Label ID="lblPostedDate" runat="server"/>
                    &nbsp;|&nbsp; Store Consumption ID: <asp:Label ID="lblStoreConsId" runat="server"/>
                </div>
            </div>
        </div>
    </asp:Panel>

    <!-- REJECTION INPUT AREA -->
    <asp:Panel ID="pnlRejectArea" runat="server" Visible="false">
        <div class="reject-area">
            <div class="reject-area-title"><i class="fas fa-times-circle"></i> Rejection Reason (Required)</div>
            <asp:TextBox ID="txtRejectReason" runat="server" CssClass="reject-textarea"
                placeholder="Explain clearly why this consumption record is being rejected…"/>
            <div style="margin-top:10px;display:flex;gap:10px;">
                <asp:Button ID="btnConfirmReject" runat="server"
                    Text="Confirm Rejection"
                    CssClass="wbtn wbtn-danger"
                    OnClick="btnConfirmReject_Click"
                    OnClientClick="if(!document.getElementById('<%= txtRejectReason.ClientID %>').value.trim()){alert('Please enter rejection reason.');return false;}return confirm('Reject this consumption record?');"/>
                <asp:Button ID="btnCancelReject" runat="server"
                    Text="Cancel"
                    CssClass="wbtn wbtn-secondary"
                    OnClick="btnCancelReject_Click"/>
            </div>
        </div>
    </asp:Panel>

    <!-- SUMMARY BAR -->
    <asp:Panel ID="pnlSummary" runat="server" Visible="false">
        <div class="summary-bar">
            <div class="sb-tile">
                <div class="sb-tile-lbl"><i class="fas fa-building"></i> Department</div>
                <div class="sb-tile-val stv-blue" style="font-size:.82rem;"><asp:Label ID="lblSumDept" runat="server"/></div>
            </div>
            <div class="sb-tile">
                <div class="sb-tile-lbl"><i class="fas fa-receipt"></i> CC ID</div>
                <div class="sb-tile-val stv-blue"><asp:Label ID="lblSumCCID" runat="server"/></div>
            </div>
            <div class="sb-tile">
                <div class="sb-tile-lbl"><i class="fas fa-list"></i> Total Ingredients</div>
                <div class="sb-tile-val"><asp:Label ID="lblSumTotal" runat="server" Text="0"/></div>
            </div>
            <div class="sb-tile">
                <div class="sb-tile-lbl"><i class="fas fa-exclamation-triangle"></i> Shortages</div>
                <div class="sb-tile-val stv-red"><asp:Label ID="lblSumShortage" runat="server" Text="0"/></div>
            </div>
            <div class="sb-tile">
                <div class="sb-tile-lbl"><i class="fas fa-exchange-alt"></i> Substitutes</div>
                <div class="sb-tile-val stv-amber"><asp:Label ID="lblSumSubstitutes" runat="server" Text="0"/></div>
            </div>
            <div class="sb-tile">
                <div class="sb-tile-lbl"><i class="fas fa-info-circle"></i> Status</div>
                <div class="sb-tile-val stv-purple" style="font-size:.8rem;"><asp:Label ID="lblSumStatus" runat="server"/></div>
            </div>
        </div>
    </asp:Panel>

    <!-- MAIN VERIFICATION GRID CARD -->
    <div class="card">
        <div class="card-head">
            <h3><i class="fas fa-table"></i> Verification Grid — Per Ingredient</h3>
            <div style="display:flex;gap:8px;flex-wrap:wrap;" id="divActionButtons" runat="server">
                <asp:Button ID="btnApproveAll" runat="server"
                    Text="Approve All"
                    CssClass="wbtn wbtn-success wbtn-sm"
                    OnClick="btnApproveAll_Click"
                    OnClientClick="return confirm('Approve ALL ingredients as-is?');"/>
                <asp:Button ID="btnRejectRecord" runat="server"
                    Text="Reject Record"
                    CssClass="wbtn wbtn-danger wbtn-sm"
                    OnClick="btnRejectRecord_Click"/>
                <asp:Button ID="btnPostToStore" runat="server"
                    Text="Post to Store"
                    CssClass="wbtn wbtn-primary wbtn-sm"
                    OnClick="btnPostToStore_Click"
                    OnClientClick="return confirm('POST consumption to store?\n\nThis will:\n• Deduct APPROVED quantities from store\n• Lock this record permanently\n• Cannot be undone\n\nAre you sure?');"/>
            </div>
        </div>
        <div class="card-body" style="padding:0;">
            <div class="table-outer" style="max-height:600px;overflow-y:auto;">
                <asp:GridView ID="gvVerification" runat="server"
                    AutoGenerateColumns="false"
                    CssClass="cc-table"
                    GridLines="None"
                    Width="100%"
                    OnRowDataBound="gvVerification_RowDataBound">
                    <Columns>

                        <%-- 1 --%>
                        <asp:TemplateField HeaderText="Ingredient" ItemStyle-Width="140px">
                            <ItemTemplate><%# Eval("IngredientName")%></ItemTemplate>
                        </asp:TemplateField>

                        <%-- 2 --%>
                        <asp:TemplateField HeaderText="Code" ItemStyle-Width="75px">
                            <ItemTemplate>
                                <span class="mono"><%# Eval("ItemCode")%></span>
                                <asp:HiddenField ID="hfDetailId"  runat="server" Value='<%# Eval("DetailId")%>'/>
                                <asp:HiddenField ID="hfItemCode"  runat="server" Value='<%# Eval("ItemCode")%>'/>
                                <asp:HiddenField ID="hfUnit"      runat="server" Value='<%# Eval("Unit")%>'/>
                                <asp:HiddenField ID="hfStockStat" runat="server" Value='<%# Eval("StockStatus")%>'/>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- 3 --%>
                        <asp:TemplateField HeaderText="Unit" ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate><%# Eval("Unit")%></ItemTemplate>
                        </asp:TemplateField>

                        <%-- 4: Expected --%>
                        <asp:TemplateField HeaderText="Expected" ItemStyle-HorizontalAlign="Right" ItemStyle-Width="75px">
                            <ItemTemplate>
                                <span class="mono"><%# string.Format("{0:N3}", Eval("ExpectedQty"))%></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- 5: Chef Actual --%>
                        <asp:TemplateField HeaderText="Chef Actual" ItemStyle-HorizontalAlign="Right" ItemStyle-Width="75px">
                            <ItemTemplate>
                                <span class="mono"><%# string.Format("{0:N3}", Eval("ActualQty"))%></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- 6: Difference --%>
                        <asp:TemplateField HeaderText="Difference" ItemStyle-HorizontalAlign="Right" ItemStyle-Width="80px">
                            <ItemTemplate>
                                <asp:Label ID="lblDiff" runat="server"/>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- 7: Store Stock --%>
                        <asp:TemplateField HeaderText="Store Stock" ItemStyle-HorizontalAlign="Right" ItemStyle-Width="80px">
                            <ItemTemplate>
                                <asp:Label ID="lblStoreStock" runat="server"/>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- 8: Shortage Reason --%>
                        <asp:TemplateField HeaderText="Shortage" ItemStyle-Width="110px">
                            <ItemTemplate>
                                <asp:Label ID="lblShortage" runat="server" style="font-size:11px;"/>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- 9: Substitute Info --%>
                        <asp:TemplateField HeaderText="Substitute" ItemStyle-Width="140px">
                            <ItemTemplate>
                                <asp:Label ID="lblSubstituteInfo" runat="server"/>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- 10: Approved Item Code --%>
                        <asp:TemplateField HeaderText="Approved Item" ItemStyle-Width="110px">
                            <ItemTemplate>
                                <asp:TextBox ID="txtApprovedItemCode" runat="server"
                                    Text='<%# Eval("ApprovedItemCode") is DBNull ? Eval("ItemCode").ToString() : Eval("ApprovedItemCode").ToString() %>'
                                    CssClass="v-input approved" style="width:100px;"
                                    Enabled='<%# hdnIsPosted.Value == "0" %>'/>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- 11: Approved Qty --%>
                        <asp:TemplateField HeaderText="Approved Qty" ItemStyle-HorizontalAlign="Right" ItemStyle-Width="90px">
                            <ItemTemplate>
                                <asp:TextBox ID="txtApprovedQty" runat="server"
                                    Text='<%# Eval("ApprovedQty") is DBNull ? string.Format("{0:N3}", Eval("ActualQty")) : string.Format("{0:N3}", Eval("ApprovedQty")) %>'
                                    CssClass="v-input" style="width:80px;text-align:right;"
                                    Enabled='<%# hdnIsPosted.Value == "0" %>'/>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- 12: Decision --%>
                        <asp:TemplateField HeaderText="Decision" ItemStyle-Width="145px">
                            <ItemTemplate>
                                <asp:DropDownList ID="ddlDecision" runat="server" CssClass="v-select"
                                    onchange="styleDecision(this)"
                                    Enabled='<%# hdnIsPosted.Value == "0" %>'>
                                    <asp:ListItem Text="— Select —"           Value=""/>
                                    <asp:ListItem Text="Approved"             Value="Approved"/>
                                    <asp:ListItem Text="Adjusted"             Value="Adjusted"/>
                                    <asp:ListItem Text="Approve Substitute"   Value="ApprovedSubstitute"/>
                                    <asp:ListItem Text="Emergency Purchase"   Value="EmergencyPurchase"/>
                                    <asp:ListItem Text="Rejected"             Value="Rejected"/>
                                </asp:DropDownList>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- 13: Verification Remarks --%>
                        <asp:TemplateField HeaderText="Verifier Remarks" ItemStyle-Width="140px">
                            <ItemTemplate>
                                <asp:TextBox ID="txtVerifRemarks" runat="server"
                                    Text='<%# Eval("VerificationRemarks")%>'
                                    CssClass="v-input" style="width:130px;"
                                    placeholder="Optional remarks…"
                                    Enabled='<%# hdnIsPosted.Value == "0" %>'/>
                            </ItemTemplate>
                        </asp:TemplateField>

                    </Columns>
                    <EmptyDataTemplate>
                        <div class="empty-state">
                            <i class="fas fa-clipboard-check"></i>
                            <h4>No Records to Verify</h4>
                            <p>Records load automatically when arriving from SearchCounter page.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>

            <!-- RULE NOTE -->
            <div style="padding:12px 18px;border-top:1px solid var(--line);background:#FAFBFF;display:flex;align-items:center;gap:8px;">
                <i class="fas fa-shield-alt" style="color:var(--purple);"></i>
                <span style="font-size:.72rem;color:var(--muted);">
                    <strong style="color:var(--ink);">Golden Rule:</strong>
                    STORE posting uses APPROVED Item Code + Approved Qty only. Chef's actual quantity is NEVER directly deducted.
                    Zero stock items require Substitute or Emergency Purchase decision before posting.
                </span>
            </div>
        </div>
    </div>

</div>

<script>
function styleDecision(sel) {
    sel.className = 'v-select';
    var v = sel.value;
    if(v === 'Approved')           sel.classList.add('decision-approved');
    else if(v === 'Adjusted')      sel.classList.add('decision-adjusted');
    else if(v === 'Rejected')      sel.classList.add('decision-rejected');
    else if(v === 'ApprovedSubstitute') sel.classList.add('decision-substitute');
    else if(v === 'EmergencyPurchase')  sel.classList.add('decision-emergency');
}
document.addEventListener('DOMContentLoaded', function(){
    document.querySelectorAll('.v-select').forEach(function(s){ styleDecision(s); });
});
</script>
</form>
</body>
</html>
