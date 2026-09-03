<%@ Page Title="Counter Close Management" Language="C#"
    MasterPageFile="~/MasterPages/GymkhanaMaster.master"
    AutoEventWireup="true" CodeFile="SearchCounter.aspx.cs"
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
    body{font-family:'Geist',system-ui,sans-serif;background:var(--surface);color:var(--ink);font-size:13.5px;line-height:1.5;}
    ::-webkit-scrollbar{width:5px;height:5px;}
    ::-webkit-scrollbar-track{background:transparent;}
    ::-webkit-scrollbar-thumb{background:var(--line-mid);border-radius:5px;}
    ::-webkit-scrollbar-thumb:hover{background:var(--blue-mid);}

    .pg{max-width:1480px;margin:0 auto;padding:18px 20px;}

    /* PAGE HEADER */
    .page-hdr{display:flex;align-items:center;justify-content:space-between;background:var(--ink);padding:0 22px;height:56px;border-radius:var(--r-lg);margin-bottom:18px;box-shadow:0 4px 18px rgba(10,15,30,.2);}
    .page-hdr-brand{display:flex;align-items:center;gap:10px;}
    .phdr-icon{width:34px;height:34px;background:linear-gradient(135deg,var(--blue),var(--blue-mid));border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:15px;color:white;box-shadow:0 4px 10px rgba(24,69,212,.4);}
    .phdr-name{color:white;font-size:.9rem;font-weight:800;letter-spacing:-.3px;}
    .phdr-sub{color:rgba(255,255,255,.38);font-size:.62rem;letter-spacing:.8px;text-transform:uppercase;}

    /* CARDS */
    .card{background:white;border-radius:var(--r-lg);box-shadow:var(--sh1);border:1px solid var(--line);margin-bottom:16px;overflow:hidden;}
    .card-head{background:linear-gradient(to right,#F7F9FF,white);padding:11px 18px;border-bottom:1px solid var(--line);display:flex;justify-content:space-between;align-items:center;}
    .card-head h3{font-size:.88rem;font-weight:800;color:var(--ink);display:flex;align-items:center;gap:7px;margin:0;}
    .card-head h3 i{color:var(--blue);font-size:13px;}
    .card-body{padding:16px 18px;}

    /* FILTER GRID */
    .filter-grid{display:grid;grid-template-columns:1fr 1fr 1fr auto;gap:14px;align-items:end;}
    .fg{display:flex;flex-direction:column;gap:5px;}
    .fg label{font-size:.67rem;font-weight:800;color:#475569;text-transform:uppercase;letter-spacing:.8px;display:flex;align-items:center;gap:5px;}
    .fg label i{color:var(--blue);font-size:10px;}
    .premium-select,.premium-input{width:100%;padding:9px 13px;border:1.5px solid var(--line);border-radius:var(--r-sm);font-family:'Geist Mono',monospace;font-size:13px;color:var(--ink);background:white;transition:all .2s;box-shadow:var(--sh1);height:40px;}
    .premium-select:focus,.premium-input:focus{border-color:var(--blue);outline:none;box-shadow:0 0 0 3px rgba(24,69,212,.1);}
    .premium-select{appearance:none;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath d='M2 4l4 4 4-4' fill='none' stroke='%237A85A0' stroke-width='1.5' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");background-repeat:no-repeat;background-position:right 12px center;padding-right:32px;cursor:pointer;}

    /* BUTTONS */
    .wbtn{padding:0 16px;border:none;border-radius:var(--r-sm);font-weight:700;font-size:12px;cursor:pointer;transition:all .2s;display:inline-flex;align-items:center;gap:6px;font-family:'Geist',sans-serif;white-space:nowrap;height:40px;}
    .wbtn-primary{background:var(--blue);color:white;box-shadow:0 2px 8px rgba(24,69,212,.22);}
    .wbtn-primary:hover{background:var(--blue-dark);transform:translateY(-1px);}
    .wbtn-danger{background:var(--red);color:white;box-shadow:0 2px 8px rgba(212,43,43,.22);}
    .wbtn-danger:hover{background:#b91c1c;transform:translateY(-1px);}
    .wbtn-action{height:34px;padding:0 14px;font-size:11.5px;background:var(--ink);color:white;border-radius:var(--r-sm);}
    .wbtn-action:hover{background:var(--blue);transform:translateY(-1px);}
    .wbtn-verify{height:34px;padding:0 14px;font-size:11.5px;background:var(--green);color:white;border-radius:var(--r-sm);}
    .wbtn-verify:hover{background:var(--green-dark);transform:translateY(-1px);}
    .btn-consumed{display:inline-flex;align-items:center;gap:6px;height:34px;padding:0 14px;font-size:11.5px;background:var(--surface);color:var(--muted);border-radius:var(--r-sm);font-weight:600;border:1px solid var(--line);cursor:default;}

    /* DEPT BANNER */
    .dept-banner{background:white;border-radius:var(--r-lg);border:1px solid var(--line);padding:16px 22px;margin-bottom:16px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:16px;box-shadow:var(--sh1);}
    .dept-info{display:flex;align-items:center;gap:14px;}
    .dept-ic{width:44px;height:44px;background:var(--blue-light);border-radius:var(--r);display:flex;align-items:center;justify-content:center;color:var(--blue);font-size:20px;}
    .dept-name{font-size:1rem;font-weight:800;color:var(--ink);}
    .dept-sub{font-size:.7rem;color:var(--muted);margin-top:2px;}
    .close-status{display:inline-flex;align-items:center;gap:7px;padding:5px 14px;border-radius:100px;font-size:.75rem;font-weight:700;}
    .status-open{background:var(--amber-light);color:var(--amber);border:1.5px solid #FDE68A;}
    .status-closed{background:var(--green-light);color:var(--green-dark);border:1.5px solid #BBF7D0;}

    /* STATS GRID */
    .stats-scroll{overflow-x:auto;margin-bottom:16px;}
    .stats-grid{display:grid;grid-template-columns:repeat(7,1fr);gap:12px;min-width:900px;}
    .stat-tile{background:white;border-radius:var(--r);padding:14px 16px;border:1px solid var(--line);transition:all .15s;}
    .stat-tile:hover{transform:translateY(-2px);box-shadow:var(--sh2);}
    .stat-tile-label{font-size:.6rem;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.7px;margin-bottom:4px;}
    .stat-tile-value{font-family:'Geist Mono',monospace;font-size:1rem;font-weight:800;}
    .stat-tile-value.green{color:var(--green-dark);}
    .stat-tile-value.red{color:var(--red);}
    .stat-tile-value.blue{color:var(--blue);}

    /* ALERT */
    .alert-box{border-radius:var(--r);padding:12px 16px;margin-bottom:16px;display:flex;align-items:center;gap:12px;}
    .alert-success{background:var(--green-light);border:2px solid #BBF7D0;color:var(--green-dark);}
    .alert-error{background:var(--red-light);border:2px solid #FECACA;color:var(--red);}
    .alert-warning{background:var(--amber-light);border:2px solid #FDE68A;color:var(--amber);}
    .alert-box i{font-size:16px;}
    .alert-box .atxt{font-weight:600;font-size:.85rem;}

    /* TABLE */
    .table-outer{overflow-x:auto;}
    .cc-table{width:100%;border-collapse:collapse;font-size:13px;font-family:'Geist',sans-serif;}
    .cc-table thead tr{background:linear-gradient(to right,#F0F4FF,#F7F9FF);}
    .cc-table th{padding:12px 14px;font-size:.64rem;font-weight:800;color:#475569;text-transform:uppercase;letter-spacing:.7px;border-bottom:2px solid var(--line);white-space:nowrap;text-align:left;}
    .cc-table td{padding:10px 14px;border-bottom:1px solid #F0F4FA;vertical-align:middle;}
    .cc-table tbody tr:hover td{background:#F7F9FF;}
    .cc-table tbody tr:nth-child(even) td{background:#FAFBFF;}
    .cc-table tbody tr:nth-child(even):hover td{background:#F0F4FF;}
    .cc-table .num{font-family:'Geist Mono',monospace;text-align:right;font-weight:600;}
    .cc-table .num.positive{color:var(--green-dark);}

    /* BADGES */
    .badge{display:inline-flex;align-items:center;gap:5px;padding:3px 10px;border-radius:100px;font-size:10.5px;font-weight:700;white-space:nowrap;}
    .badge-closed{background:var(--green-light);color:var(--green-dark);border:1px solid #BBF7D0;}
    .badge-open{background:var(--amber-light);color:var(--amber);border:1px solid #FDE68A;}
    .badge-consumed{background:var(--blue-light);color:var(--blue);border:1px solid #BFDBFE;}
    .badge-pending{background:var(--red-light);color:var(--red);border:1px solid #FECACA;}

    /* EMPTY STATE */
    .empty-state{text-align:center;padding:48px 20px;background:linear-gradient(135deg,#F7F9FF,#F1F5FF);border-radius:var(--r);border:2px dashed #C0CFFF;margin:16px;}
    .empty-state i{font-size:38px;color:#C0CFFF;margin-bottom:10px;display:block;}
    .empty-state h4{color:var(--blue);margin-bottom:5px;font-size:.98rem;font-weight:800;}
    .empty-state p{color:var(--muted);font-size:.84rem;}

    @media(max-width:1100px){.stats-grid{grid-template-columns:repeat(4,1fr);}}
    @media(max-width:900px){.filter-grid{grid-template-columns:1fr;}.stats-grid{grid-template-columns:repeat(2,1fr);}}
    @media(max-width:768px){.dept-banner{flex-direction:column;align-items:flex-start;}.stats-grid{grid-template-columns:1fr;}}
</style>

<div class="pg">

    <!-- PAGE HEADER -->
    <div class="page-hdr">
        <div class="page-hdr-brand">
            <div class="phdr-icon"><i class="fas fa-store"></i></div>
            <div>
                <div class="phdr-name">Counter Close Management</div>
                <div class="phdr-sub">Search records, view summaries &amp; manage counter closures</div>
            </div>
        </div>
    </div>

    <!-- SEARCH CARD -->
    <div class="card">
        <div class="card-head">
            <h3><i class="fas fa-search"></i> Search &amp; Filter Records</h3>
        </div>
        <div class="card-body">
            <div class="filter-grid">
                <div class="fg">
                    <label><i class="fas fa-building"></i> Sub Department <span style="color:var(--red);">*</span></label>
                    <asp:DropDownList ID="ddlSubDept" runat="server" CssClass="premium-select"
                        AutoPostBack="true"
                        OnSelectedIndexChanged="ddlSubDept_SelectedIndexChanged">
                    </asp:DropDownList>
                </div>
                <div class="fg">
                    <label><i class="fas fa-calendar-alt"></i> From Date</label>
                    <asp:TextBox ID="txtFromDate" runat="server" TextMode="Date" CssClass="premium-input" />
                </div>
                <div class="fg">
                    <label><i class="fas fa-calendar-check"></i> To Date</label>
                    <asp:TextBox ID="txtToDate" runat="server" TextMode="Date" CssClass="premium-input" />
                </div>
                <div class="fg">
                    <label style="visibility:hidden;">&nbsp;</label>
                    <asp:Button ID="btnSearch" runat="server" Text="Search Records"
                        CssClass="wbtn wbtn-primary" OnClick="btnSearch_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- HIDDEN FIELDS -->
    <asp:HiddenField ID="hdnDeptId" runat="server" />
    <asp:HiddenField ID="hdnDeptName" runat="server" />

    <!-- ALERT -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <div id="divAlert" runat="server" class="alert-box">
            <i class="fas fa-info-circle"></i>
            <div class="atxt">
                <asp:Label ID="lblAlertMessage" runat="server" />
            </div>
        </div>
    </asp:Panel>

    <!-- DEPARTMENT BANNER -->
    <asp:Panel ID="pnlDepartmentInfo" runat="server" Visible="false">
        <div class="dept-banner">
            <div class="dept-info">
                <div class="dept-ic"><i class="fas fa-building"></i></div>
                <div>
                    <div class="dept-name"><asp:Label ID="lblDepartmentName" runat="server" /></div>
                    <div class="dept-sub">Counter close records for selected department</div>
                </div>
            </div>
            <div class="dept-right" style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
                <div class="close-status" id="divCloseStatus" runat="server">
                    <asp:Literal ID="litStatusIcon" runat="server" />
                    <asp:Literal ID="litStatusText" runat="server" />
                </div>
                <asp:Button ID="btnCloseCounterNow" runat="server"
                    Text="Close Counter Now"
                    CssClass="wbtn wbtn-danger"
                    OnClick="btnCloseCounterNow_Click"
                    OnClientClick="return confirm('Are you sure you want to close this counter?\n\nThis will lock all today\'s sales records for this department.');" />
            </div>
        </div>
    </asp:Panel>

    <!-- STATS GRID -->
    <asp:Panel ID="pnlStats" runat="server" Visible="false">
        <div class="stats-scroll">
            <div class="stats-grid">
                <div class="stat-tile">
                    <div class="stat-tile-label"><i class="fas fa-coins"></i> Total Sales</div>
                    <div class="stat-tile-value green">Rs <asp:Label ID="lblTotalSales" runat="server" Text="0" /></div>
                </div>
                <div class="stat-tile">
                    <div class="stat-tile-label"><i class="fas fa-credit-card"></i> Card Sales</div>
                    <div class="stat-tile-value blue">Rs <asp:Label ID="lblTotalCardSales" runat="server" Text="0" /></div>
                </div>
                <div class="stat-tile">
                    <div class="stat-tile-label"><i class="fas fa-id-card"></i> Member Card</div>
                    <div class="stat-tile-value blue">Rs <asp:Label ID="lblTotalMemberCardSales" runat="server" Text="0" /></div>
                </div>
                <div class="stat-tile">
                    <div class="stat-tile-label"><i class="fas fa-tag"></i> Discount</div>
                    <div class="stat-tile-value red">Rs <asp:Label ID="lblTotalDiscount" runat="server" Text="0" /></div>
                </div>
                <div class="stat-tile">
                    <div class="stat-tile-label"><i class="fas fa-receipt"></i> Tax</div>
                    <div class="stat-tile-value blue">Rs <asp:Label ID="lblTotalTax" runat="server" Text="0" /></div>
                </div>
                <div class="stat-tile">
                    <div class="stat-tile-label"><i class="fas fa-money-bill-wave"></i> Net Amount</div>
                    <div class="stat-tile-value green">Rs <asp:Label ID="lblNetAmount" runat="server" Text="0" /></div>
                </div>
                <div class="stat-tile">
                    <div class="stat-tile-label"><i class="fas fa-list"></i> Records</div>
                    <div class="stat-tile-value"><asp:Label ID="lblRecordCount" runat="server" Text="0" /></div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <!-- GRID CARD -->
    <div class="card">
        <div class="card-head">
            <h3><i class="fas fa-table"></i> Counter Close Records</h3>
        </div>
        <div class="card-body" style="padding:0;">
            <div class="table-outer">
                <asp:GridView ID="gvCounterClose" runat="server"
                    AutoGenerateColumns="False"
                    CssClass="cc-table"
                    OnRowCommand="gvCounterClose_RowCommand"
                    GridLines="None"
                    ShowHeaderWhenEmpty="True"
                    EmptyDataText="No records found for the selected criteria.">
                    <Columns>
                        <asp:BoundField DataField="CounterCloseId" HeaderText="ID" ItemStyle-Width="60px" />
                        <asp:BoundField DataField="Emp_Id" HeaderText="Employee" ItemStyle-Width="90px" />
                        <asp:TemplateField HeaderText="Counter Status" ItemStyle-Width="130px">
                            <ItemTemplate>
                                <%# Convert.ToString(Eval("CounterStatus")) == "Closed"
                                    ? "<span class='badge badge-closed'><i class='fas fa-lock'></i> Closed</span>"
                                    : "<span class='badge badge-open'><i class='fas fa-lock-open'></i> Open</span>" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Consumption" ItemStyle-Width="120px">
                            <ItemTemplate>
                                <%# Convert.ToString(Eval("ConsumedStatus")) == "Consumed"
                                    ? "<span class='badge badge-consumed'><i class='fas fa-check-circle'></i> Consumed</span>"
                                    : "<span class='badge badge-pending'><i class='fas fa-clock'></i> Pending</span>" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="TotalSales" HeaderText="Sales (Rs.)"
                            DataFormatString="{0:N2}"
                            ItemStyle-HorizontalAlign="Right"
                            ItemStyle-CssClass="num positive" />
                        <asp:BoundField DataField="CardSales" HeaderText="Card (Rs.)"
                            DataFormatString="{0:N2}"
                            ItemStyle-HorizontalAlign="Right"
                            ItemStyle-CssClass="num" />
                        <asp:BoundField DataField="MemberCardSales" HeaderText="Member (Rs.)"
                            DataFormatString="{0:N2}"
                            ItemStyle-HorizontalAlign="Right"
                            ItemStyle-CssClass="num" />
                        <asp:BoundField DataField="TotalDiscount" HeaderText="Discount (Rs.)"
                            DataFormatString="{0:N2}"
                            ItemStyle-HorizontalAlign="Right"
                            ItemStyle-CssClass="num" />
                        <asp:BoundField DataField="TotalTax" HeaderText="Tax (Rs.)"
                            DataFormatString="{0:N2}"
                            ItemStyle-HorizontalAlign="Right"
                            ItemStyle-CssClass="num" />
                        <asp:BoundField DataField="CloseDate" HeaderText="Close Date"
                            DataFormatString="{0:dd-MMM-yyyy hh:mm tt}"
                            ItemStyle-Width="150px" />
                        <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="160px">
                            <ItemTemplate>
                                <asp:Button ID="btnMark" runat="server"
                                    Text="Mark as Consumption"
                                    CssClass="wbtn wbtn-action"
                                    CommandName="MarkConsumption"
                                    CommandArgument='<%# Eval("CounterCloseId") + "|" + Eval("Emp_Id") %>'
                                    Visible='<%# Convert.ToString(Eval("ConsumedStatus")) != "Consumed" %>' />
                                
                                <asp:Button ID="btnVerify" runat="server"
                                    Text="Consumption Verify"
                                    CssClass="wbtn wbtn-verify"
                                    CommandName="VerifyConsumption"
                                    CommandArgument='<%# Eval("CounterCloseId") + "|" + Eval("Emp_Id") %>'
                                    Visible='<%# Convert.ToString(Eval("ConsumedStatus")) == "Consumed" %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="empty-state">
                            <i class="fas fa-clipboard-list"></i>
                            <h4>No Records Found</h4>
                            <p>No counter close records match the selected criteria.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </div>

</div>

</asp:Content>
