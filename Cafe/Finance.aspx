<%@ Page Title="Counter Close Management" Language="C#"
    MasterPageFile="~/MasterPages/GymkhanaMaster.master"
    AutoEventWireup="true" CodeFile="Finance.aspx.cs"
    Inherits="Kitchen_assign" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700;800;900&family=Geist+Mono:wght@400;500;600&display=swap" rel="stylesheet" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

<style>
    :root {
        --ink:#0A0F1E;
        --blue:#1845D4;--blue-light:#EEF3FF;--blue-dark:#0F2D8A;--blue-mid:#4070F4;
        --surface:#F4F6FB;--line:#DDE3EF;--line-mid:#C8D0E0;--muted:#7A85A0;
        --green:#0E9E52;--green-light:#EDFAF4;--green-dark:#075C30;
        --amber:#D4820A;--amber-light:#FFF8ED;
        --red:#D42B2B;--red-light:#FFF0F0;
        --purple:#6B35D4;--purple-light:#F3EEFF;
        --teal:#0A9E8E;--teal-light:#EDFAF8;
        --sh1:0 1px 3px rgba(10,15,30,.07),0 1px 2px rgba(10,15,30,.05);
        --sh2:0 4px 12px rgba(10,15,30,.08),0 2px 4px rgba(10,15,30,.05);
        --sh4:0 24px 48px rgba(10,15,30,.12);
        --r:10px;--r-sm:7px;--r-lg:14px;--r-xl:18px;
    }
    *{margin:0;padding:0;box-sizing:border-box;}
    body,.content-wrapper,.wrapper{font-family:'Geist',system-ui,sans-serif!important;background:var(--surface)!important;color:var(--ink)!important;font-size:13.5px;line-height:1.5;}
    ::-webkit-scrollbar{width:5px;height:5px;}
    ::-webkit-scrollbar-track{background:transparent;}
    ::-webkit-scrollbar-thumb{background:var(--line-mid);border-radius:5px;}
    ::-webkit-scrollbar-thumb:hover{background:var(--blue-mid);}

    .cc-wrap{max-width:1640px;margin:0 auto;padding:18px 20px;}

    .page-hdr{display:flex;align-items:center;justify-content:space-between;background:var(--ink);padding:0 22px;height:56px;border-radius:var(--r-lg);margin-bottom:18px;box-shadow:0 4px 18px rgba(10,15,30,.2);}
    .page-hdr-brand{display:flex;align-items:center;gap:10px;}
    .phdr-icon{width:34px;height:34px;background:linear-gradient(135deg,var(--blue),var(--blue-mid));border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:15px;color:white;box-shadow:0 4px 10px rgba(24,69,212,.4);}
    .phdr-name{color:white;font-size:.9rem;font-weight:800;letter-spacing:-.3px;}
    .phdr-sub{color:rgba(255,255,255,.38);font-size:.62rem;letter-spacing:.8px;text-transform:uppercase;}
    .phdr-right{display:flex;align-items:center;gap:10px;}
    .sel-pill{display:inline-flex;align-items:center;gap:6px;background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.12);color:rgba(255,255,255,.7);border-radius:100px;padding:4px 13px;font-size:.72rem;font-weight:600;font-family:'Geist Mono',monospace;}
    .btn-post{background:linear-gradient(135deg,var(--green-dark),var(--green));color:white;border:none;border-radius:7px;padding:6px 16px;font-family:'Geist',sans-serif;font-size:.78rem;font-weight:700;cursor:pointer;transition:all .2s;display:inline-flex;align-items:center;gap:6px;box-shadow:0 3px 10px rgba(14,158,82,.3);}
    .btn-post:hover{transform:translateY(-1px);box-shadow:0 6px 16px rgba(14,158,82,.4);}
    .btn-post:disabled{background:linear-gradient(135deg,#94A3B8,#CBD5E1);box-shadow:none;cursor:not-allowed;opacity:.7;}

    .card{background:white;border-radius:var(--r-lg);box-shadow:var(--sh1);border:1px solid var(--line);margin-bottom:16px;overflow:hidden;}
    .card-head{background:linear-gradient(to right,#F7F9FF,white);padding:11px 18px;border-bottom:1px solid var(--line);display:flex;justify-content:space-between;align-items:center;}
    .card-head h3{font-size:.88rem;font-weight:800;color:var(--ink);display:flex;align-items:center;gap:7px;margin:0;}
    .card-head h3 i{color:var(--blue);font-size:13px;}
    .card-body{padding:16px 18px;}

    .filter-grid{display:grid;grid-template-columns:1fr 1fr auto;gap:14px;align-items:end;}
    .fg{display:flex;flex-direction:column;gap:5px;}
    .fg label{font-size:.67rem;font-weight:800;color:#475569;text-transform:uppercase;letter-spacing:.8px;display:flex;align-items:center;gap:5px;}
    .fg label i{color:var(--blue);font-size:10px;}
    .premium-input{width:100%;padding:9px 13px;border:1.5px solid var(--line);border-radius:var(--r-sm);font-family:'Geist Mono',monospace;font-size:13px;color:var(--ink);background:white;transition:all .2s;box-shadow:var(--sh1);height:40px;}
    .premium-input:focus{border-color:var(--blue);outline:none;box-shadow:0 0 0 3px rgba(24,69,212,.1);}
    .filter-actions{display:flex;gap:9px;}

    .wbtn{padding:0 16px;border:none;border-radius:var(--r-sm);font-weight:700;font-size:12px;cursor:pointer;transition:all .2s;display:inline-flex;align-items:center;gap:6px;font-family:'Geist',sans-serif;white-space:nowrap;height:40px;}
    .wbtn-primary{background:var(--blue);color:white;box-shadow:0 2px 8px rgba(24,69,212,.22);}
    .wbtn-primary:hover{background:var(--blue-dark);transform:translateY(-1px);}
    .wbtn-outline{background:white;color:var(--muted);border:1.5px solid var(--line);}
    .wbtn-outline:hover{background:var(--blue);color:white;border-color:var(--blue);transform:translateY(-1px);}
    .wbtn-info{background:#0284C7;color:white;box-shadow:0 2px 8px rgba(2,132,199,.22);}
    .wbtn-info:hover{background:#0369A1;transform:translateY(-1px);}

    /* STATS */
    .stats-grid{display:grid;grid-template-columns:repeat(5,1fr);gap:12px;}
    .stat-tile{border-radius:var(--r);padding:14px 16px;display:flex;flex-direction:column;gap:6px;transition:transform .15s,box-shadow .15s;}
    .stat-tile:hover{transform:translateY(-2px);box-shadow:var(--sh2);}
    .stat-tile-label{font-size:.63rem;font-weight:800;text-transform:uppercase;letter-spacing:.7px;display:flex;align-items:center;gap:5px;}
    .stat-tile-label i{font-size:10px;}
    .stat-tile-value{font-family:'Geist Mono',monospace;font-size:1.1rem;font-weight:800;letter-spacing:-.5px;}
    .st-sales{background:var(--green-light);border:1px solid #A7F3D0;}
    .st-sales .stat-tile-label,.st-sales .stat-tile-value{color:var(--green-dark);}
    .st-bank{background:var(--blue-light);border:1px solid #BFDBFE;}
    .st-bank .stat-tile-label,.st-bank .stat-tile-value{color:var(--blue-dark);}
    .st-member{background:var(--purple-light);border:1px solid #DDD6FE;}
    .st-member .stat-tile-label,.st-member .stat-tile-value{color:var(--purple);}
    .st-disc{background:var(--amber-light);border:1px solid #FDE68A;}
    .st-disc .stat-tile-label,.st-disc .stat-tile-value{color:var(--amber);}
    .st-tax{background:#EFF6FF;border:1px solid #BFDBFE;}
    .st-tax .stat-tile-label,.st-tax .stat-tile-value{color:#0284C7;}

    .table-outer{overflow-x:auto;}
    .cc-table{width:100%;border-collapse:collapse;font-size:13px;font-family:'Geist',sans-serif;}
    .cc-table thead tr{background:linear-gradient(to right,#F0F4FF,#F7F9FF);}
    .cc-table th{padding:10px 14px;font-size:.64rem;font-weight:800;color:#475569;text-transform:uppercase;letter-spacing:.7px;border-bottom:2px solid var(--line);white-space:nowrap;text-align:left;}
    .cc-table td{padding:10px 14px;border-bottom:1px solid #F0F4FA;vertical-align:middle;white-space:nowrap;}
    .cc-table tbody tr:hover td{background:#F7F9FF;}
    .cc-table tbody tr:nth-child(even) td{background:#FAFBFF;}
    .cc-table tbody tr:nth-child(even):hover td{background:#F0F4FF;}
    .cc-table tbody tr.row-posted td{background:#F0FDF6!important;}
    .cc-table tbody tr.row-posted:hover td{background:#E6FAF0!important;}

    .cell-id{font-family:'Geist Mono',monospace;font-weight:700;color:var(--blue);font-size:.88rem;}
    .cell-date{font-family:'Geist Mono',monospace;font-size:.8rem;color:#475569;}
    .cell-amt{font-family:'Geist Mono',monospace;font-weight:700;color:var(--green);}
    .cell-disc{font-family:'Geist Mono',monospace;font-weight:700;color:var(--amber);}
    .cell-tax{font-family:'Geist Mono',monospace;font-weight:700;color:#0284C7;}
    .cell-dept{display:inline-flex;align-items:center;gap:4px;background:var(--blue-light);color:var(--blue);padding:2px 9px;border-radius:100px;font-size:.72rem;font-weight:700;}
    .cell-emp{display:inline-flex;align-items:center;gap:4px;background:var(--purple-light);color:var(--purple);padding:2px 9px;border-radius:100px;font-size:.72rem;font-weight:700;}

    .cc-check{width:15px;height:15px;accent-color:var(--blue);cursor:pointer;}
    .th-chk{display:flex;align-items:center;justify-content:center;}

    .voucher-badge{display:inline-flex;align-items:center;gap:5px;background:var(--green-light);color:var(--green-dark);border:1px solid #A7F3D0;padding:4px 11px;border-radius:100px;font-size:.72rem;font-weight:800;font-family:'Geist Mono',monospace;white-space:nowrap;box-shadow:0 1px 4px rgba(14,158,82,.12);}
    .voucher-badge i{font-size:10px;color:var(--green);}

    .pager-row{display:flex;align-items:center;justify-content:center;gap:4px;padding:12px 18px;border-top:1px solid var(--line);background:linear-gradient(to right,#F7F9FF,white);}
    .pager-row a,.pager-row span{display:inline-block;padding:5px 12px;background:white;border:1.5px solid var(--line);color:var(--muted);border-radius:6px;font-size:.72rem;font-family:'Geist Mono',monospace;font-weight:700;text-decoration:none;transition:all .18s;}
    .pager-row a:hover{background:var(--blue);color:white;border-color:var(--blue);}
    .pager-row span.current{background:var(--blue);color:white;border-color:var(--blue);}

    .empty-state{text-align:center;padding:48px 20px;background:linear-gradient(135deg,#F7F9FF,#F1F5FF);border-radius:var(--r);border:2px dashed #C0CFFF;margin:16px;}
    .empty-state i{font-size:38px;color:#C0CFFF;margin-bottom:10px;display:block;}
    .empty-state h4{color:var(--blue);margin-bottom:5px;font-size:.98rem;font-weight:800;}
    .empty-state p{color:var(--muted);font-size:.84rem;}
    .cc-msg{text-align:center;padding:18px;font-size:.84rem;font-weight:700;display:block;}

    .modal-overlay{display:none;position:fixed;inset:0;background:rgba(10,15,30,.6);z-index:9999;align-items:flex-start;justify-content:center;padding:28px 16px;overflow-y:auto;backdrop-filter:blur(4px);}
    .modal-overlay.active{display:flex;}
    .modal-box{background:white;border-radius:var(--r-xl);box-shadow:var(--sh4);width:100%;max-width:1200px;animation:slideIn .15s cubic-bezier(.34,1.2,.64,1);border:1px solid rgba(255,255,255,.5);overflow:hidden;}
    @keyframes slideIn{from{transform:scale(.95) translateY(-14px);opacity:0;}to{transform:scale(1) translateY(0);opacity:1;}}
    .modal-head{background:linear-gradient(to right,#EEF3FF,white);padding:13px 20px;border-bottom:1px solid var(--line);display:flex;justify-content:space-between;align-items:center;position:sticky;top:0;z-index:10;}
    .modal-head h3{font-size:.95rem;font-weight:800;color:var(--ink);display:flex;align-items:center;gap:8px;margin:0;}
    .modal-head h3 i{color:var(--blue);}
    .modal-close{background:none;border:none;font-size:1rem;cursor:pointer;color:#94A3B8;width:30px;height:30px;display:flex;align-items:center;justify-content:center;border-radius:7px;transition:all .2s;}
    .modal-close:hover{background:var(--red-light);color:var(--red);}
    .modal-body{padding:18px 20px;max-height:74vh;overflow-y:auto;}
    .modal-body::-webkit-scrollbar{width:5px;}
    .modal-body::-webkit-scrollbar-thumb{background:var(--line-mid);border-radius:5px;}
    .modal-foot{padding:12px 20px;border-top:1px solid var(--line);background:linear-gradient(to right,#F7F9FF,white);display:flex;justify-content:flex-end;gap:9px;}

    .section-title{font-size:.65rem;font-weight:800;text-transform:uppercase;letter-spacing:.9px;color:#475569;padding:8px 12px;background:linear-gradient(to right,#F0F4FF,#F7F9FF);border-radius:var(--r-sm);margin-bottom:12px;border-left:3px solid var(--blue);display:flex;align-items:center;gap:7px;}
    .section-title.alt{border-left-color:var(--amber);}
    .section-title i{font-size:11px;color:var(--blue);}
    .section-title.alt i{color:var(--amber);}

    .inner-table{width:100%;border-collapse:collapse;font-size:12.5px;}
    .inner-table th{background:#F7F9FC;padding:8px 12px;font-weight:700;color:#475569;border-bottom:2px solid var(--line);text-align:left;font-size:.65rem;text-transform:uppercase;letter-spacing:.5px;white-space:nowrap;}
    .inner-table td{padding:8px 12px;border-bottom:1px solid #F0F4FA;vertical-align:middle;white-space:nowrap;}
    .inner-table tbody tr:hover td{background:#F7F9FF;}
    .inner-table tbody tr:nth-child(even) td{background:#FAFBFF;}

    #loadingPanel{display:none;text-align:center;padding:28px;}
    .spin-ring{width:36px;height:36px;border:3px solid var(--line);border-top-color:var(--blue);border-radius:50%;animation:spin .8s linear infinite;margin:0 auto 10px;}
    @keyframes spin{to{transform:rotate(360deg);}}
    .spin-label{font-size:.8rem;color:var(--muted);font-weight:600;}
    #billItemsPanel{display:none;margin-top:18px;}

    @media(max-width:900px){.stats-grid{grid-template-columns:repeat(2,1fr);}}
    @media(max-width:768px){.filter-grid{grid-template-columns:1fr;}.stats-grid{grid-template-columns:1fr;}.page-hdr{flex-direction:column;height:auto;padding:12px;gap:10px;border-radius:var(--r);}}
</style>

<div class="cc-wrap">

    <!-- PAGE HEADER -->
    <div class="page-hdr">
        <div class="page-hdr-brand">
            <div class="phdr-icon"><i class="fas fa-cash-register"></i></div>
            <div>
                <div class="phdr-name">Counter Close Management</div>
                <div class="phdr-sub">Finance &amp; Reports</div>
            </div>
        </div>
        <div class="phdr-right">
            <div class="sel-pill" id="selCountLabel">
                <i class="fas fa-check-square" style="font-size:10px;color:rgba(255,255,255,.4);"></i>
                0 selected
            </div>
            <asp:Button ID="btnPostSelected" runat="server"
                Text="POST Selected"
                CssClass="btn-post"
                OnClick="btnPostSelected_Click"
                Enabled="false" 
                UseSubmitBehavior="true" />
        </div>
    </div>

    <!-- FILTER -->
    <div class="card">
        <div class="card-head">
            <h3><i class="fas fa-sliders-h"></i> Filter Records</h3>
        </div>
        <div class="card-body">
            <div class="filter-grid">
                <div class="fg">
                    <label><i class="fas fa-calendar-alt"></i> Start Date</label>
                    <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="premium-input"></asp:TextBox>
                </div>
                <div class="fg">
                    <label><i class="fas fa-calendar-check"></i> End Date</label>
                    <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="premium-input"></asp:TextBox>
                </div>
                <div class="filter-actions">
                    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="wbtn wbtn-primary" OnClick="btnSearch_Click" />
                    <asp:Button ID="btnReset"  runat="server" Text="Reset"  CssClass="wbtn wbtn-outline" OnClick="btnReset_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- PAGE STATS CARD -->
    <div class="card" id="statsCard" style="display:none;">
        <div class="card-head">
            <h3><i class="fas fa-chart-bar"></i> Page Summary Totals</h3>
            <span style="font-size:.7rem;color:var(--muted);font-family:'Geist Mono',monospace;" id="statsNote"></span>
        </div>
        <div class="card-body">
            <div class="stats-grid">
                <div class="stat-tile st-sales">
                    <div class="stat-tile-label"><i class="fas fa-coins"></i> Total Sales</div>
                    <div class="stat-tile-value" id="statTotalSales">Rs 0</div>
                </div>
                <div class="stat-tile st-bank">
                    <div class="stat-tile-label"><i class="fas fa-credit-card"></i> Bank Card</div>
                    <div class="stat-tile-value" id="statBankCard">Rs 0</div>
                </div>
                <div class="stat-tile st-member">
                    <div class="stat-tile-label"><i class="fas fa-id-card"></i> Member Card</div>
                    <div class="stat-tile-value" id="statMemberCard">Rs 0</div>
                </div>
                <div class="stat-tile st-disc">
                    <div class="stat-tile-label"><i class="fas fa-tag"></i> Total Discount</div>
                    <div class="stat-tile-value" id="statDiscount">Rs 0</div>
                </div>
                <div class="stat-tile st-tax">
                    <div class="stat-tile-label"><i class="fas fa-receipt"></i> Total Tax</div>
                    <div class="stat-tile-value" id="statTax">Rs 0</div>
                </div>
            </div>
        </div>
    </div>

    <!-- SELECTED RECORDS STATS CARD -->
    <div class="card" id="selectedStatsCard" style="display:none; margin-bottom:16px;">
        <div class="card-head" style="background: linear-gradient(135deg, #EFF6FF, #F0FDF4);">
            <h3><i class="fas fa-check-square"></i> Selected Records Summary</h3>
            <span style="font-size:.7rem;color:var(--green-dark);font-weight:700;" id="selectedCountLabel"></span>
        </div>
        <div class="card-body">
            <div class="stats-grid">
                <div class="stat-tile st-sales">
                    <div class="stat-tile-label"><i class="fas fa-coins"></i> Selected Sales</div>
                    <div class="stat-tile-value" id="selectedTotalSales">Rs 0</div>
                </div>
                <div class="stat-tile st-bank">
                    <div class="stat-tile-label"><i class="fas fa-credit-card"></i> Selected Bank Card</div>
                    <div class="stat-tile-value" id="selectedBankCard">Rs 0</div>
                </div>
                <div class="stat-tile st-member">
                    <div class="stat-tile-label"><i class="fas fa-id-card"></i> Selected Member Card</div>
                    <div class="stat-tile-value" id="selectedMemberCard">Rs 0</div>
                </div>
                <div class="stat-tile st-disc">
                    <div class="stat-tile-label"><i class="fas fa-tag"></i> Selected Discount</div>
                    <div class="stat-tile-value" id="selectedDiscount">Rs 0</div>
                </div>
                <div class="stat-tile st-tax">
                    <div class="stat-tile-label"><i class="fas fa-receipt"></i> Selected Tax</div>
                    <div class="stat-tile-value" id="selectedTax">Rs 0</div>
                </div>
            </div>
        </div>
    </div>

    <!-- MAIN TABLE CARD -->
    <div class="card">
        <div class="card-head">
            <h3><i class="fas fa-table"></i> Counter Close Transactions</h3>
            <span style="font-size:.72rem;color:var(--muted);font-family:'Geist Mono',monospace;" id="rowCountLabel"></span>
        </div>

        <div class="table-outer">
            <asp:GridView ID="gvCounterClose" runat="server" AutoGenerateColumns="False"
                CssClass="cc-table"
                AllowPaging="True" PageSize="10"
                OnPageIndexChanging="gvCounterClose_PageIndexChanging"
                ShowHeaderWhenEmpty="True"
                OnRowDataBound="gvCounterClose_RowDataBound">

                <Columns>
                    <asp:TemplateField ItemStyle-Width="50px"
                        HeaderStyle-HorizontalAlign="Center"
                        ItemStyle-HorizontalAlign="Center">
                        <HeaderTemplate>
                            <div class="th-chk">
                                <input type="checkbox" class="cc-check" id="chkAll"
                                       onclick="toggleAll(this)" title="Select all unposted" />
                            </div>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <%# (Eval("VoucherId") != DBNull.Value && Eval("VoucherId") != null && Convert.ToInt32(Eval("VoucherId")) > 0)
                                ? string.Format("<span class='voucher-badge'><i class='fas fa-check-circle'></i>{0}</span>", Eval("VoucherId"))
                                : string.Format("<input type='checkbox' class='cc-check row-check' value='{0}' onclick='updateSelection()' />", Eval("CounterCloseId"))
                            %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Close ID" ItemStyle-Width="100px"
                        HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate><span class="cell-id">#<%# Eval("CounterCloseId") %></span></ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Close Date" ItemStyle-Width="160px"
                        HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate><span class="cell-date"><%# Eval("CloseDate", "{0:yyyy-MM-dd HH:mm}") %></span></ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Total Sales" ItemStyle-Width="130px"
                        HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate><span class="cell-amt">Rs <%# string.Format("{0:N0}", Eval("TotalSales")) %></span></ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Bank Card" ItemStyle-Width="120px"
                        HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate><span class="cell-amt">Rs <%# string.Format("{0:N0}", Eval("BankcardSales")) %></span></ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Member Card" ItemStyle-Width="120px"
                        HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate><span class="cell-amt">Rs <%# string.Format("{0:N0}", Eval("MemberCardSales")) %></span></ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Discount" ItemStyle-Width="110px"
                        HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate><span class="cell-disc">Rs <%# string.Format("{0:N0}", Eval("TotalDiscount")) %></span></ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Tax" ItemStyle-Width="100px"
                        HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate><span class="cell-tax">Rs <%# string.Format("{0:N0}", Eval("TotalTax")) %></span></ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Dept" ItemStyle-Width="100px"
                        HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <span class="cell-dept">
                                <i class="fas fa-building" style="font-size:9px;"></i>
                                <%# Eval("DepartmentID") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Employee" ItemStyle-Width="100px"
                        HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <span class="cell-emp">
                                <i class="fas fa-user" style="font-size:9px;"></i>
                                <%# Eval("Emp_Id") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Action" ItemStyle-Width="120px"
                        HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <asp:Button ID="btnView" runat="server" Text="View Details"
                                CssClass="wbtn wbtn-info"
                                style="padding:0 12px;height:32px;font-size:11.5px;"
                                CommandArgument='<%# Eval("CounterCloseId") %>'
                                OnClick="btnView_Click" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>

                <EmptyDataTemplate>
                    <div class="empty-state">
                        <i class="fas fa-clipboard-list"></i>
                        <h4>No Records Found</h4>
                        <p>No counter close records match the selected date range.</p>
                    </div>
                </EmptyDataTemplate>

                <PagerStyle CssClass="pager-row" HorizontalAlign="Center" />
                <HeaderStyle BackColor="Transparent" />
                <RowStyle BackColor="Transparent" />
                <AlternatingRowStyle BackColor="Transparent" />
            </asp:GridView>
        </div>

        <asp:Label ID="lblMessage" runat="server" Text="" CssClass="cc-msg"></asp:Label>
    </div>

</div>

<!-- DETAILS MODAL -->
<div id="detailsModal" class="modal-overlay">
    <div class="modal-box">
        <div class="modal-head">
            <h3><i class="fas fa-layer-group"></i> Counter Close — Bill Details</h3>
            <button class="modal-close" onclick="hideModal()"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <div class="section-title"><i class="fas fa-receipt"></i> Bills for this Counter Close</div>
            <div style="overflow-x:auto;">
                <asp:GridView ID="gvBills" runat="server" AutoGenerateColumns="False"
                    CssClass="inner-table" Width="100%"
                    OnRowCommand="gvBills_RowCommand"
                    ShowHeaderWhenEmpty="True">
                    <Columns>
                        <asp:TemplateField HeaderText="Bill ID" ItemStyle-Width="80px"
                            HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate><span class="cell-id">#<%# Eval("Id") %></span></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Member" ItemStyle-Width="100px">
                            <ItemTemplate>
                                <span class="cell-dept" style="background:var(--blue-light);">
                                    <i class="fas fa-user" style="font-size:9px;"></i><%# Eval("MemberNo") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Subtotal" ItemStyle-Width="100px"
                            HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate><span class="cell-amt"><%# string.Format("{0:N0}", Eval("Subtotal")) %></span></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Discount" ItemStyle-Width="90px"
                            HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate><span class="cell-disc"><%# string.Format("{0:N0}", Eval("DiscountApplied")) %></span></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Tax" ItemStyle-Width="80px"
                            HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate><span class="cell-tax"><%# string.Format("{0:N0}", Eval("TaxApplied")) %></span></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Amount Paid" ItemStyle-Width="110px"
                            HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <span style="font-family:'Geist Mono',monospace;font-weight:800;color:var(--green);font-size:.88rem;">
                                    Rs <%# string.Format("{0:N0}", Eval("AmountPaid")) %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="bill_to"       HeaderText="Bill To"  ItemStyle-Width="110px" />
                        <asp:BoundField DataField="PaymentMethod" HeaderText="Method"   ItemStyle-Width="100px" />
                        <asp:TemplateField HeaderText="Card #" ItemStyle-Width="120px">
                            <ItemTemplate>
                                <span style="font-family:'Geist Mono',monospace;font-size:.78rem;color:var(--muted);">
                                    <%# Eval("CardNumber") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="CashierName" HeaderText="Cashier" ItemStyle-Width="110px" />
                        <asp:TemplateField HeaderText="Payment Date" ItemStyle-Width="140px"
                            HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate><span class="cell-date"><%# Eval("PaymentDate", "{0:yyyy-MM-dd HH:mm}") %></span></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Items" ItemStyle-Width="100px"
                            ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <asp:Button ID="btnShowItems" runat="server"
                                    Text="Show Items"
                                    CssClass="wbtn wbtn-primary"
                                    style="padding:0 10px;height:30px;font-size:11px;"
                                    CommandName="ShowItems"
                                    CommandArgument='<%# Eval("Id") %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <HeaderStyle BackColor="Transparent" />
                    <RowStyle BackColor="Transparent" />
                    <AlternatingRowStyle BackColor="Transparent" />
                </asp:GridView>
            </div>

            <div id="loadingPanel">
                <div class="spin-ring"></div>
                <div class="spin-label">Loading bill items…</div>
            </div>

            <div id="billItemsPanel">
                <div class="section-title alt" style="margin-top:6px;">
                    <i class="fas fa-list-ul"></i> Bill Items Detail
                </div>
                <div style="overflow-x:auto;">
                    <asp:GridView ID="gvBillItems" runat="server" AutoGenerateColumns="False"
                        CssClass="inner-table" Width="100%">
                        <Columns>
                            <asp:TemplateField HeaderText="Item ID" ItemStyle-Width="80px"
                                HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate><span class="cell-id"><%# Eval("MenuItemId") %></span></ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="Name" HeaderText="Item Name" ItemStyle-Width="200px" />
                            <asp:TemplateField HeaderText="Price" ItemStyle-Width="100px"
                                HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right">
                                <ItemTemplate><span class="cell-amt"><%# string.Format("{0:N0}", Eval("Price")) %></span></ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="Quantity" HeaderText="Qty" ItemStyle-Width="60px"
                                ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                            <asp:TemplateField HeaderText="Line Total" ItemStyle-Width="110px"
                                HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <span style="font-family:'Geist Mono',monospace;font-weight:800;color:var(--green);">
                                        <%# string.Format("{0:N0}", Eval("LineTotal")) %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="KOT #" ItemStyle-Width="90px"
                                ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <span style="background:var(--blue-light);color:var(--blue);padding:2px 9px;border-radius:100px;font-family:'Geist Mono',monospace;font-size:.78rem;font-weight:700;">
                                        <%# Eval("KOT_Number") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="Cover" HeaderText="Cover" ItemStyle-Width="70px"
                                ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                        </Columns>
                        <HeaderStyle BackColor="Transparent" />
                        <RowStyle BackColor="Transparent" />
                        <AlternatingRowStyle BackColor="Transparent" />
                    </asp:GridView>
                </div>
            </div>
        </div>
        <div class="modal-foot">
            <button class="wbtn wbtn-outline" onclick="hideModal()">
                <i class="fas fa-times"></i> Close
            </button>
        </div>
    </div>
</div>

<asp:HiddenField ID="hdnSelectedIds" runat="server" />

<!-- Pure JavaScript - Only for UI updates, NO ALERTS -->
<script>
    // Parse number function
    function parseNum(element) {
        if (!element) return 0;
        var txt = element.innerText || element.textContent || '';
        var num = txt.replace(/Rs/gi, '').replace(/,/g, '').trim();
        return parseInt(num) || 0;
    }

    // Format Rupees
    function fmtRs(n) {
        return 'Rs ' + n.toLocaleString('en-PK');
    }

    // Toggle all checkboxes
    function toggleAll(masterChk) {
        var boxes = document.querySelectorAll('.row-check');
        for (var i = 0; i < boxes.length; i++) {
            boxes[i].checked = masterChk.checked;
        }
        updateSelection();
    }

    // Update selection and stats
    function updateSelection() {
        try {
            var all = document.querySelectorAll('.row-check');
            var checked = document.querySelectorAll('.row-check:checked');
            var count = checked.length;
            var total = all.length;
            
            var selLabel = document.getElementById('selCountLabel');
            if (selLabel) {
                selLabel.innerHTML = '<i class="fas fa-check-square" style="font-size:10px;color:rgba(255,255,255,.4);"></i> ' + count + ' selected';
            }
            
            var ids = [];
            for (var i = 0; i < checked.length; i++) {
                ids.push(checked[i].value);
            }
            
            var hdn = document.getElementById('<%= hdnSelectedIds.ClientID %>');
            if (hdn) hdn.value = ids.join(',');
            
            var btn = document.getElementById('<%= btnPostSelected.ClientID %>');
            if (btn) btn.disabled = (count === 0);

            var chkAll = document.getElementById('chkAll');
            if (chkAll) {
                chkAll.indeterminate = (count > 0 && count < total);
                chkAll.checked = (total > 0 && count === total);
            }

            computeSelectedStats();

        } catch (e) {
            console.log('Error in updateSelection:', e.message);
        }
    }

    // Compute stats for selected records
    function computeSelectedStats() {
        try {
            var boxes = document.querySelectorAll('.row-check:checked');
            var selectedCard = document.getElementById('selectedStatsCard');

            if (boxes.length === 0) {
                if (selectedCard) selectedCard.style.display = 'none';
                return;
            }

            var sales = 0, bank = 0, member = 0, disc = 0, tax = 0;

            for (var i = 0; i < boxes.length; i++) {
                var row = boxes[i].closest('tr');
                if (row) {
                    var tds = row.querySelectorAll('td');
                    if (tds.length >= 8) {
                        sales += parseNum(tds[3]);
                        bank += parseNum(tds[4]);
                        member += parseNum(tds[5]);
                        disc += parseNum(tds[6]);
                        tax += parseNum(tds[7]);
                    }
                }
            }

            var elements = {
                selectedTotalSales: document.getElementById('selectedTotalSales'),
                selectedBankCard: document.getElementById('selectedBankCard'),
                selectedMemberCard: document.getElementById('selectedMemberCard'),
                selectedDiscount: document.getElementById('selectedDiscount'),
                selectedTax: document.getElementById('selectedTax'),
                selectedCountLabel: document.getElementById('selectedCountLabel')
            };

            if (elements.selectedTotalSales) elements.selectedTotalSales.innerText = fmtRs(sales);
            if (elements.selectedBankCard) elements.selectedBankCard.innerText = fmtRs(bank);
            if (elements.selectedMemberCard) elements.selectedMemberCard.innerText = fmtRs(member);
            if (elements.selectedDiscount) elements.selectedDiscount.innerText = fmtRs(disc);
            if (elements.selectedTax) elements.selectedTax.innerText = fmtRs(tax);
            if (elements.selectedCountLabel) elements.selectedCountLabel.innerHTML = boxes.length + ' record(s) selected';

            if (selectedCard) selectedCard.style.display = 'block';

        } catch (e) {
            console.log('Error in computeSelectedStats:', e.message);
        }
    }

    // Compute stats for current page
    function computeStats() {
        try {
            var tbl = document.querySelector('table.cc-table');
            var card = document.getElementById('statsCard');

            if (!tbl) {
                if (card) card.style.display = 'none';
                return;
            }

            var rows = tbl.querySelectorAll('tbody tr');
            if (rows.length === 0) {
                if (card) card.style.display = 'none';
                return;
            }

            var sales = 0, bank = 0, member = 0, disc = 0, tax = 0;

            for (var i = 0; i < rows.length; i++) {
                var tds = rows[i].querySelectorAll('td');
                if (tds.length >= 8) {
                    sales += parseNum(tds[3]);
                    bank += parseNum(tds[4]);
                    member += parseNum(tds[5]);
                    disc += parseNum(tds[6]);
                    tax += parseNum(tds[7]);
                }
            }

            var elements = {
                statTotalSales: document.getElementById('statTotalSales'),
                statBankCard: document.getElementById('statBankCard'),
                statMemberCard: document.getElementById('statMemberCard'),
                statDiscount: document.getElementById('statDiscount'),
                statTax: document.getElementById('statTax'),
                rowCountLabel: document.getElementById('rowCountLabel')
            };

            if (elements.statTotalSales) elements.statTotalSales.innerText = fmtRs(sales);
            if (elements.statBankCard) elements.statBankCard.innerText = fmtRs(bank);
            if (elements.statMemberCard) elements.statMemberCard.innerText = fmtRs(member);
            if (elements.statDiscount) elements.statDiscount.innerText = fmtRs(disc);
            if (elements.statTax) elements.statTax.innerText = fmtRs(tax);
            if (elements.rowCountLabel) elements.rowCountLabel.innerHTML = rows.length + ' record' + (rows.length === 1 ? '' : 's');

            if (card) card.style.display = 'block';

        } catch (e) {
            console.log('Error in computeStats:', e.message);
        }
    }

    // Modal functions
    function showModal() {
        var modal = document.getElementById('detailsModal');
        if (modal) modal.classList.add('active');
        document.body.style.overflow = 'hidden';
    }

    function hideModal() {
        var modal = document.getElementById('detailsModal');
        if (modal) modal.classList.remove('active');
        document.body.style.overflow = '';
        var billPanel = document.getElementById('billItemsPanel');
        var loadingPanel = document.getElementById('loadingPanel');
        if (billPanel) billPanel.style.display = 'none';
        if (loadingPanel) loadingPanel.style.display = 'none';
    }

    function showBillItems() {
        var loadingPanel = document.getElementById('loadingPanel');
        var billPanel = document.getElementById('billItemsPanel');
        if (loadingPanel) loadingPanel.style.display = 'none';
        if (billPanel) {
            billPanel.style.display = 'block';
            setTimeout(function () {
                billPanel.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }, 120);
        }
    }

    // Initialize on page load
    document.addEventListener('DOMContentLoaded', function () {
        computeStats();
        computeSelectedStats();
        updateSelection();

        // Modal close on outside click
        var modalElem = document.getElementById('detailsModal');
        if (modalElem) {
            modalElem.addEventListener('click', function (e) {
                if (e.target === this) hideModal();
            });
        }

        // Escape key close
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') hideModal();
        });
    });

    // For UpdatePanel
    if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
        var prm = Sys.WebForms.PageRequestManager.getInstance();
        if (prm) {
            prm.add_endRequest(function () {
                computeStats();
                computeSelectedStats();
                updateSelection();
            });
        }
    }
</script>

</asp:Content>
