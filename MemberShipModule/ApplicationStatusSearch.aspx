<%@ Page Title="Application Status Explorer" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true"
    CodeFile="ApplicationStatusSearch.aspx.cs" Inherits="Membership.ApplicationStatusSearch" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Outfit', sans-serif !important; background-color: #faf7f2; }
        
        .table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.95rem;
            text-align: left;
        }

        .table th {
            background: #faf7f2;
            color: #8B5E3C;
            font-weight: 700;
            padding: 0.75rem 1rem;
            border-bottom: 1px solid #e0d5c5;
            text-align: left;
            font-size: 0.875rem;
        }

        .table td {
            padding: 0.75rem 1rem;
            border-bottom: 1px solid #F7F3EE;
            color: #1A1A2E;
            vertical-align: middle;
            font-size: 0.9rem;
        }

        .table tr:hover {
            background-color: #faf7f2;
        }

        /* Status Colors */
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.4rem 0.8rem;
            border-radius: 99px;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
        }
        .status-pending { background: #fef3c7; color: #92400e; border: 1px solid #fde68a; }
        .status-approved { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
        .status-interview { background: #f5ecd5; color: #0369a1; border: 1px solid #e0d5c5; }
        .status-other { background: #F7F3EE; color: #8B5E3C; border: 1px solid #e0d5c5; }

        /* Pagination */
        .pagination-premium td { padding: 1rem; background: #fff; text-align: center; border-top: 1px solid #e0d5c5; }
        .pagination-premium a, .pagination-premium span {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 32px;
            height: 32px;
            margin: 0 4px;
            border-radius: 6px;
            font-size: 0.875rem;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.2s;
        }
        .pagination-premium a { color: #7a7a7a; background: #ffffff; border: 1px solid #e0d5c5; }
        .pagination-premium a:hover { background: #F7F3EE; border-color: #e0d5c5; color: #1A1A2E; }
        .pagination-premium span { background: #C9A84C; color: #ffffff; border: 1px solid #C9A84C; }

        .form-control:focus {
            border-color: #8B5E3C !important;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1) !important;
            outline: none;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-wrapper" style="padding: 1.5rem; width: 100%; max-width: 100%; margin: 0 auto;">
        
        <div class="card" style="background-color: #ffffff; border-radius: 12px; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden;">
            
            <!-- Card Header -->
            <div class="card-header" style="padding: 1.5rem; border-bottom: 1px solid #e0d5c5; display: flex; justify-content: space-between; align-items: center; background: #ffffff;">
                <div>
                    <h1 style="font-size: 1.5rem; font-weight: 700; color:black; margin: 0;">Application Status Explorer</h1>
                    <p style="color: black; font-size: 0.95rem; margin: 0.25rem 0 0 0;">Track and manage membership applications with precision.</p>
                </div>
                <div>
                    <asp:Label ID="lblCount" runat="server" 
                        style="padding: 0.5rem 1rem; border-radius: 99px; font-size: 0.85rem; font-weight: 600; background: #F7F3EE; color: #8B5E3C; border: 1px solid #e0d5c5;" 
                        Text="System Ready" />
                </div>
            </div>

            <!-- Search Area -->
            <div class="card-body" style="padding: 1.5rem;">
                
                <div style="margin-bottom: 2rem;">
                    <div style="position: relative; margin-bottom: 1rem;">
                        <span style="position: absolute; left: 1rem; top: 50%; transform: translateY(-50%); color: #a09080;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                            </svg>
                        </span>
                        <asp:TextBox ID="txtUniversalSearch" runat="server" CssClass="form-control"
                            placeholder="Quick search by Tracker ID, Name, CNIC, or Mobile..." 
                            style="width: 100%; padding: 0.875rem 1rem 0.875rem 3rem; font-size: 1.1rem; color: #1A1A2E; border: 1px solid #e0d5c5; border-radius: 8px; transition: all 0.2s;" />
                    </div>

                    <div style="display: flex; gap: 0.75rem; justify-content: space-between; align-items: center;">
                        <div style="display: flex; gap: 0.75rem;">
                            <button type="button" onclick="toggleAdvanced()" id="btnToggleAdvanced" 
                                style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background-color: white; color: #1A1A2E; border: 1px solid #e0d5c5; display: flex; align-items: center; gap: 0.5rem; transition: all 0.2s;">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <line x1="4" y1="21" x2="4" y2="14"></line><line x1="4" y1="10" x2="4" y2="3"></line>
                                    <line x1="12" y1="21" x2="12" y2="12"></line><line x1="12" y1="8" x2="12" y2="3"></line>
                                    <line x1="20" y1="21" x2="20" y2="16"></line><line x1="20" y1="12" x2="20" y2="3"></line>
                                    <line x1="1" y1="14" x2="7" y2="14"></line><line x1="9" y1="8" x2="15" y2="8"></line><line x1="17" y1="16" x2="23" y2="16"></line>
                                </svg>
                                Filters <span id="chevron" style="font-size: 0.7rem; transition: transform 0.2s;">▼</span>
                            </button>
                            <asp:Button ID="btnClear" runat="server" Text="Reset" OnClick="btnClear_Click"
                                style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background-color: white; color: #7a7a7a; border: 1px solid #e0d5c5; transition: all 0.2s;" />
                        </div>
                        <asp:Button ID="btnSearch" runat="server" Text="Search Applications" OnClick="btnSearch_Click"
                            style="padding: 0.75rem 2rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; border: none; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2); transition: all 0.2s;" />
                    </div>
                </div>

                <!-- Advanced Filters -->
                <div id="advancedFilters" style="display: none; padding: 1.5rem; background: #faf7f2; border-radius: 12px; border: 1px solid #e0d5c5; margin-bottom: 2rem;">
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1.25rem;">
                        <div style="display: flex; flex-direction: column; gap: 0.4rem;">
                            <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">SR#</label>
                            <asp:TextBox ID="txtTrackID" runat="server" placeholder="Enter SR#..." CssClass="form-control" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px;" />
                        </div>
                        <div style="display: flex; flex-direction: column; gap: 0.4rem;">
                            <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Applicant Name</label>
                            <asp:TextBox ID="txtApplicantName" runat="server" CssClass="form-control" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px;" />
                        </div>
                        <div style="display: flex; flex-direction: column; gap: 0.4rem;">
                            <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">CNIC Number</label>
                            <asp:TextBox ID="txtNIC" runat="server" CssClass="form-control" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px;" />
                        </div>
                        <div style="display: flex; flex-direction: column; gap: 0.4rem;">
                            <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Apply Date</label>
                            <asp:TextBox ID="txtApplyDate" runat="server" TextMode="Date" CssClass="form-control" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px;" />
                        </div>
                        <div style="display: flex; flex-direction: column; gap: 0.4rem;">
                            <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Mobile No</label>
                            <asp:TextBox ID="txtMobile" runat="server" CssClass="form-control" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px;" />
                        </div>
                        <div style="display: flex; flex-direction: column; gap: 0.4rem;">
                            <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Status</label>
                            <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; background: white;">
                                <asp:ListItem Text="All Statuses" Value=""></asp:ListItem>
                                <asp:ListItem Text="Pending" Value="Pending"></asp:ListItem>
                                <asp:ListItem Text="Approved" Value="Approved"></asp:ListItem>
                                <asp:ListItem Text="ShortList" Value="Call for interview"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div style="display: flex; flex-direction: column; gap: 0.4rem;">
                            <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Type</label>
                            <asp:DropDownList ID="ddlType" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlType_SelectedIndexChanged" CssClass="form-control" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; background: white;">
                                <asp:ListItem Text="All Types" Value=""></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div style="display: flex; flex-direction: column; gap: 0.4rem;">
                            <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Class</label>
                            <asp:DropDownList ID="ddlClass" runat="server" CssClass="form-control" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; background: white;">
                                <asp:ListItem Text="All Classes" Value=""></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div style="display: flex; flex-direction: column; gap: 0.4rem;">
                            <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Sort Order</label>
                            <asp:DropDownList ID="ddlSortOrder" runat="server" CssClass="form-control" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; background: white;">
                                <asp:ListItem Text="Oldest First" Value="ASC"></asp:ListItem>
                                <asp:ListItem Text="Newest First" Value="DESC"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>

                <!-- Results Grid -->
                <div style="border: 1px solid #e0d5c5; border-radius: 8px; overflow: hidden;">
                    <asp:GridView ID="gvResults" runat="server" AutoGenerateColumns="False" 
                        CssClass="table" GridLines="None" Width="100%" AllowPaging="true" PageSize="15"
                        OnPageIndexChanging="gvResults_PageIndexChanging">
                        
                        <PagerStyle CssClass="pagination-premium" HorizontalAlign="Center" />
                        
                        <Columns>
                            <asp:TemplateField HeaderText="SR#">
                                <ItemTemplate>
                                    <a href='ApplicationProcessing.aspx?id=<%# Eval("TrackID") %>' 
                                       style="color: #C9A84C; font-weight: 700; text-decoration: none; display: flex; align-items: center; gap: 0.5rem;">
                                        <span style="background: #faf7f2; padding: 4px 8px; border-radius: 6px; border: 1px solid #f5ecd5;">#<%# Eval("TrackID") %></span>
                                    </a>
                                </ItemTemplate>
                                <HeaderStyle Width="100px" />
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Applicant Details">
                                <ItemTemplate>
                                    <div style="font-weight: 600; color: #1A1A2E;"><%# Eval("ApplicantName") %></div>
                                    <div style="font-size: 0.8rem; color: #7a7a7a;">S/O: <%# Eval("FatherName") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Contact Info">
                                <ItemTemplate>
                                    <div style="color: #1A1A2E;"><%# Eval("NIC") %></div>
                                    <div style="font-size: 0.8rem; color: #7a7a7a;"><%# Eval("Mobile") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Type">
                                <ItemTemplate>
                                    <span style="background: #f3e8ff; color: #7c3aed; padding: 2px 8px; border-radius: 4px; font-size: 0.75rem; font-weight: 600; border: 1px solid #e9d5ff;">
                                        <%# Eval("Membership_class") %> - <%# Eval("MembershipType") %>
                                    </span>
                                </ItemTemplate>
                                <HeaderStyle Width="200px" />
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <span class='status-badge <%# GetStatusClass(Eval("Status")) %>'>
                                        <%# Eval("Status") %>
                                    </span>
                                    <div style="margin-top: 4px; font-size: 0.75rem; color: #a09080;">
                                        <%# Eval("ApplyDate") != DBNull.Value ? Eval("ApplyDate", "{0:dd MMM yyyy}") : "N/A" %>
                                    </div>
                                </ItemTemplate>
                                <HeaderStyle Width="180px" />
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <a href='ApplicationProcessing.aspx?id=<%# Eval("TrackID") %>' 
                                       style="display: inline-flex; align-items: center; justify-content: center; width: 32px; height: 32px; border-radius: 6px; background: #ffffff; border: 1px solid #e0d5c5; color: #C9A84C; transition: all 0.2s; text-decoration: none;">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                            <path d="M5 12h14"></path><path d="m12 5 7 7-7 7"></path>
                                        </svg>
                                    </a>
                                </ItemTemplate>
                                <HeaderStyle Width="80px" />
                            </asp:TemplateField>
                        </Columns>

                        <EmptyDataTemplate>
                            <div style="padding: 4rem 2rem; text-align: center;">
                                <h3 style="color: #7a7a7a; font-weight: 600;">No records found matching your criteria.</h3>
                                <p style="color: #a09080;">Try adjusting your filters or search terms.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

            </div>
        </div>

    </div>

    <script type="text/javascript">
        function toggleAdvanced() {
            var panel = document.getElementById('advancedFilters');
            var chevron = document.getElementById('chevron');
            var btn = document.getElementById('btnToggleAdvanced');

            if (panel.style.display === 'none' || panel.style.display === '') {
                panel.style.display = 'block';
                chevron.style.transform = 'rotate(180deg)';
                btn.style.borderColor = '#C9A84C';
                btn.style.color = '#C9A84C';
            } else {
                panel.style.display = 'none';
                chevron.style.transform = 'rotate(0deg)';
                btn.style.borderColor = '#e0d5c5';
                btn.style.color = '#1A1A2E';
            }
        }
    </script>
</asp:Content>
