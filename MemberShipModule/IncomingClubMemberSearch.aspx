<%@ Page Title="Incoming Club Member Search" Language="C#" MasterPageFile="~/MemberShipModule/Site.master"
    AutoEventWireup="true" CodeFile="IncomingClubMemberSearch.aspx.cs" Inherits="IncomingClubMemberSearch" %>
    <asp:Content ID="HeadStyles" ContentPlaceHolderID="HeadContent" runat="server">
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <style>
            body { font-family: 'Outfit', sans-serif !important; background-color: #faf7f2; }
            .table-container { background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
            .table { width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left; }
            .table th { background: #1A1A2E; color: #C9A84C; font-weight: 700; padding: 0.75rem 1rem; border-bottom: 1px solid #e0d5c5; text-align: left; font-size: 0.875rem; }
            .table td { padding: 0.75rem 1rem; border-bottom: 1px solid #F7F3EE; color: #1A1A2E; vertical-align: middle; font-size: 0.9rem; }
            .table tr:hover { background-color: #faf7f2; }
            .form-control { display: block; width: 100%; padding: 0.6rem 0.8rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; outline: none; box-sizing: border-box; }
            .form-control:focus { border-color: #C9A84C; }
        </style>
    </asp:Content>


<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .search-page { width: 98%; margin: 0 auto; padding: 1.5rem 0; font-family: 'Outfit', sans-serif; }
        .search-header { display: flex; align-items: center; gap: 14px; margin-bottom: 20px; padding-bottom: 16px; border-bottom: 1px solid #e0d5c5; }
        .search-header .icon-wrap { width: 48px; height: 48px; background: linear-gradient(135deg, #8B5E3C, #C9A84C); border-radius: 12px; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 1.3rem; flex-shrink: 0; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2); }
        .search-header h1 { font-size: 1.5rem; font-weight: 700; color: #1A1A2E; margin: 0; }
        .search-header p { color: #8B5E3C; margin: 2px 0 0; font-size: 0.875rem; font-weight: 500; }

        .search-card { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1); border: 1px solid #e0d5c5; margin-bottom: 16px; }
        .search-card-title { font-size: 0.95rem; font-weight: 700; color: #1A1A2E; margin: 0 0 15px; display: flex; align-items: center; gap: 8px; border-bottom: 1px solid #F7F3EE; padding-bottom: 10px; text-transform: uppercase; letter-spacing: 0.5px; }
        
        .filters-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px 20px; margin-bottom: 15px; }
        .filter-group { display: flex; flex-direction: column; }
        .filter-group label { font-size: 0.75rem; font-weight: 700; color: #8B5E3C; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 5px; }
        .filter-group input, .filter-group select { padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; font-size: 0.85rem; transition: 0.2s; outline: none; background: white; color: #1A1A2E; }
        .filter-group input:focus, .filter-group select:focus { border-color: #C9A84C; }

        .actions-row { display: flex; justify-content: space-between; align-items: center; padding-top: 15px; border-top: 1px dashed #e0d5c5; margin-top: 5px; }
        .btn-group { display: flex; gap: 10px; }
        
        .btn-search { background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; border: none; padding: 9px 20px; border-radius: 7px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; font-size: 0.85rem; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2); }
        .btn-search:hover { box-shadow: 0 6px 10px rgba(201, 168, 76, 0.3); }
        .btn-report { background: #ffffff; color: #7a7a7a; border: 1px solid #e0d5c5; padding: 9px 20px; border-radius: 7px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; font-size: 0.85rem; transition: 0.2s; }
        .btn-report:hover { background: #faf7f2; border-color: #a09080; color: #1e293b; }

        .results-grid { width: 100%; border-collapse: collapse; margin-top: 10px; }
        .results-grid th { background: #1A1A2E; color: #C9A84C; font-size: 0.875rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; padding: 12px; border-bottom: 1px solid #e0d5c5; text-align: left; }
        .results-grid td { padding: 12px; border-bottom: 1px solid #F7F3EE; font-size: 0.9rem; color: #1A1A2E; vertical-align: middle; }
        .results-grid tr:hover td { background: #faf7f2; }

        .badge-active { background: #dcfce7; color: #166534; padding: 4px 10px; border-radius: 12px; font-size: 0.75rem; font-weight: 700; border: 1px solid #bbf7d0; text-transform: uppercase; }
        .badge-inactive { background: #fee2e2; color: #991b1b; padding: 4px 10px; border-radius: 12px; font-size: 0.75rem; font-weight: 700; border: 1px solid #fecaca; text-transform: uppercase; }
        
        .btn-icon-only { background: none; border: none; cursor: pointer; color: #7a7a7a; transition: 0.2s; font-size: 1rem; }
        .btn-icon-only:hover { color: #8B5E3C; }
    </style>

    <div class="search-page">
        <!-- Header -->
        <div class="search-header">
            <div class="icon-wrap">
                <i class="fas fa-search"></i>
            </div>
            <div>
                <h1>Incoming Club Member Search & Reporting</h1>
                <p>Advanced filtering and monthly, yearly, or clubwise visit reporting</p>
            </div>
        </div>

        <asp:UpdatePanel ID="upSearch" runat="server">
            <ContentTemplate>
                <!-- Filters Card -->
                <div class="search-card">
                    <div class="search-card-title"><i class="fas fa-filter"></i> Search Criteria</div>
                    
                    <div class="filters-grid">
                        <div class="filter-group">
                            <label>Letter No</label>
                            <asp:TextBox ID="txtIntroNo" runat="server" placeholder="e.g. INTRO-2026..." />
                        </div>
                        <div class="filter-group">
                            <label>Guest Name</label>
                            <asp:TextBox ID="txtGuestName" runat="server" placeholder="Search by name..." />
                        </div>
                         <div class="filter-group">
                            <label>Member Number</label>
                            <asp:TextBox ID="txtMemberNo" runat="server" placeholder="Enter member no..." />
                        </div>
                        <div class="filter-group">
                            <label>Affiliated Club</label>
                            <asp:DropDownList ID="ddlClub" runat="server" />
                        </div>
                        
                        <div class="filter-group">
                            <label>Month</label>
                            <asp:DropDownList ID="ddlMonth" runat="server">
                                <asp:ListItem Text="-- All Months --" Value="0" />
                                <asp:ListItem Text="January" Value="1" />
                                <asp:ListItem Text="February" Value="2" />
                                <asp:ListItem Text="March" Value="3" />
                                <asp:ListItem Text="April" Value="4" />
                                <asp:ListItem Text="May" Value="5" />
                                <asp:ListItem Text="June" Value="6" />
                                <asp:ListItem Text="July" Value="7" />
                                <asp:ListItem Text="August" Value="8" />
                                <asp:ListItem Text="September" Value="9" />
                                <asp:ListItem Text="October" Value="10" />
                                <asp:ListItem Text="November" Value="11" />
                                <asp:ListItem Text="December" Value="12" />
                            </asp:DropDownList>
                        </div>
                        <div class="filter-group">
                            <label>Year</label>
                            <asp:DropDownList ID="ddlYear" runat="server" />
                        </div>
                        <div class="filter-group">
                            <label>From Date</label>
                            <asp:TextBox ID="txtDateFrom" runat="server" TextMode="Date" />
                        </div>
                        <div class="filter-group">
                            <label>To Date</label>
                            <asp:TextBox ID="txtDateTo" runat="server" TextMode="Date" />
                        </div>
                    </div>

                    <div class="actions-row">
                        <div class="btn-group">
                             <asp:LinkButton ID="btnSearch" runat="server" CssClass="btn-search" OnClick="btnSearch_Click" style="background: #8B5E3C; color: white; border: none; padding: 9px 20px; border-radius: 7px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; font-size: 0.85rem; text-decoration: none;">
                                <i class="fas fa-search"></i> Search Records
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnClear" runat="server" CssClass="btn-report" OnClick="btnClear_Click" style="background: #ffffff; color: #8B5E3C; border: 1px solid #d1d5db; padding: 9px 20px; border-radius: 7px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; font-size: 0.85rem; text-decoration: none;">
                                <i class="fas fa-undo"></i> Reset
                            </asp:LinkButton>
                        </div>
                        <div class="btn-group">
                            <asp:LinkButton ID="btnPrintList" runat="server" CssClass="btn-report" OnClick="btnPrintList_Click" style="background: #ffffff; color: #8B5E3C; border: 1px solid #d1d5db; padding: 9px 20px; border-radius: 7px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; font-size: 0.85rem; text-decoration: none;">
                                <i class="fas fa-print"></i> Print List Report
                            </asp:LinkButton>
                             <asp:LinkButton ID="btnPrintSummary" runat="server" CssClass="btn-report" OnClick="btnPrintSummary_Click" style="background: #ffffff; color: #8B5E3C; border: 1px solid #d1d5db; padding: 9px 20px; border-radius: 7px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; font-size: 0.85rem; text-decoration: none;">
                                <i class="fas fa-chart-pie"></i> Clubwise Summary
                            </asp:LinkButton>
                        </div>
                    </div>
                </div>

                <!-- Results Table Card -->
                <div class="search-card">
                    <div class="search-card-title"><i class="fas fa-list"></i> Search Results</div>
                    <div style="overflow-x: auto;">
                        <asp:GridView ID="gvResults" runat="server" AutoGenerateColumns="false" CssClass="results-grid"
                            DataKeyNames="Id" OnRowCommand="gvResults_RowCommand" EmptyDataText="No records found matching the criteria.">
                                <HeaderStyle BackColor="#faf7f2" ForeColor="#1A1A2E" Font-Bold="True" Height="40px" HorizontalAlign="Left" BorderColor="#e0d5c5" BorderStyle="Solid" BorderWidth="1px" />
                                <RowStyle BackColor="White" ForeColor="#1A1A2E" BorderColor="#e0d5c5" BorderStyle="Solid" BorderWidth="1px" Height="48px" />
                                <AlternatingRowStyle BackColor="#faf7f2" ForeColor="#1A1A2E" BorderColor="#e0d5c5" BorderStyle="Solid" BorderWidth="1px" Height="48px" />
                            <Columns>
                                <asp:BoundField DataField="IntroductoryNo" HeaderText="Letter No" ItemStyle-Width="120px" />
                                <asp:BoundField DataField="MemberNo" HeaderText="Member #" ItemStyle-Width="80px" />
                                <asp:BoundField DataField="MemberName" HeaderText="Guest Name" />
                                <asp:BoundField DataField="ClubName" HeaderText="Affiliated Club" />
                                <asp:TemplateField HeaderText="Visit Period">
                                    <ItemTemplate>
                                        <%# Convert.ToDateTime(Eval("DateFrom")).ToString("dd-MMM") %> to 
                                        <%# Convert.ToDateTime(Eval("DateTo")).ToString("dd-MMM-yyyy") %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Status" ItemStyle-Width="80px">
                                    <ItemTemplate>
                                        <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                                            <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Closed" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Actions" ItemStyle-Width="120px">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditItem" 
                                            CommandArgument='<%# Eval("Id") %>' CssClass="btn-icon-only" ToolTip="View/Edit">
                                            <i class="fas fa-edit"></i>
                                        </asp:LinkButton>
                                        &nbsp;&nbsp;
                                        <asp:LinkButton ID="btnPrint" runat="server" CommandName="PrintItem" 
                                            CommandArgument='<%# Eval("Id") %>' CssClass="btn-icon-only" ToolTip="Print Letter" ForeColor="#10b981">
                                            <i class="fas fa-print"></i>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </ContentTemplate>
            <Triggers>
                <asp:PostBackTrigger ControlID="btnPrintList" />
                <asp:PostBackTrigger ControlID="btnPrintSummary" />
                <asp:PostBackTrigger ControlID="gvResults" />
            </Triggers>
        </asp:UpdatePanel>
    </div>
</asp:Content>
