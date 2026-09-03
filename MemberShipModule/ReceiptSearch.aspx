<%@ Page Title="Receipt Explorer" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true" CodeFile="ReceiptSearch.aspx.cs" Inherits="ReceiptSearch" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
    <style type="text/css">
        .btn-premium-search { 
            background: linear-gradient(135deg, #C9A84C 0%, #8B5E3C 100%); 
            color: #ffffff !important; 
            border: none; 
            padding: 8px 20px; 
            border-radius: 6px; 
            font-weight: 700; 
            font-size: 0.85rem; 
            cursor: pointer; 
            display: inline-flex; 
            align-items: center; 
            justify-content: center; 
            gap: 8px; 
            transition: all 0.2s ease; 
            box-shadow: 0 2px 4px rgba(201, 168, 76, 0.15);
            text-decoration: none;
            text-transform: none;
            letter-spacing: normal;
        }
        .btn-premium-search:hover { 
            background: linear-gradient(135deg, #1d4ed8 0%, #C9A84C 100%); 
            transform: translateY(-1px); 
            box-shadow: 0 6px 12px rgba(201, 168, 76, 0.3); 
        }
        .btn-premium-search:active {
            transform: translateY(0);
        }
        
        .btn-view-report {
            display: inline-flex; 
            align-items: center; 
            gap: 4px; 
            padding: 4px 10px; 
            background: #ffffff;
            color: #342867; 
            text-decoration: none; 
            font-weight: 600; 
            font-size: 0.8rem; 
            border-radius: 4px;
            border: 1px solid #e0d5c5; 
            transition: all 0.2s ease;
        }
        .btn-view-report:hover { 
            background: #faf7f2; 
            color: #4b3a8a; 
            border-color: #342867;
            transform: scale(1.02);
        }
        
        .form-input-focus:focus { 
            border-color: #C9A84C !important; 
            outline: none !important; 
            box-shadow: 0 0 0 3px rgba(201, 168, 76, 0.15) !important; 
            background-color: #fff !important;
        }

        .gv-row-premium:hover td { 
            background-color: #F7F3EE !important; 
            transition: background-color 0.2s ease;
        }

        /* Standardized Grid Text */
        .gv-header-text { 
            color: #8B5E3C !important; 
            font-weight: 700 !important; 
            text-transform: uppercase !important; 
            letter-spacing: 0.05em !important;
            font-size: 0.7rem !important;
            padding: 8px 12px !important;
            border-bottom: 2px solid #F7F3EE !important;
        }
        .gv-header-first { padding-left: 16px !important; }
        .gv-header-right { text-align: right !important; }
        .gv-header-center { text-align: center !important; }

        .gv-cell-standard {
            padding: 10px 12px !important;
            border-bottom: 1px solid #F7F3EE !important;
            vertical-align: middle !important;
            font-size: 0.875rem !important;
        }
        .gv-cell-first { padding-left: 16px !important; }
        .gv-cell-right { text-align: right !important; }
        .gv-cell-center { text-align: center !important; }
        .gv-cell-bold { color: #1A1A2E !important; font-weight: 600 !important; }

        /* Premium Pagination Styles */
        .gv-pager-premium table {
            margin: 20px auto 10px auto !important;
            border-collapse: separate !important;
            border-spacing: 6px !important;
        }
        .gv-pager-premium td {
            padding: 0 !important;
            border: none !important;
            background: transparent !important;
        }
        .gv-pager-premium a, .gv-pager-premium span {
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            min-width: 34px;
            height: 34px;
            padding: 0 8px;
            text-decoration: none !important;
            border-radius: 8px !important;
            font-weight: 700 !important;
            font-size: 0.85rem !important;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1) !important;
            border: 1px solid #e0d5c5 !important;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05) !important;
        }
        .gv-pager-premium a {
            background-color: #ffffff !important;
            color: #8B5E3C !important;
        }
        .gv-pager-premium a:hover {
            background-color: #faf7f2 !important;
            color: #C9A84C !important;
            border-color: #C9A84C !important;
            transform: translateY(-1px);
            box-shadow: 0 4px 6px rgba(201, 168, 76, 0.15) !important;
        }
        .gv-pager-premium span {
            background: linear-gradient(135deg, #C9A84C 0%, #8B5E3C 100%) !important;
            color: #ffffff !important;
            border: 1px solid #8B5E3C !important;
            box-shadow: 0 2px 4px rgba(201, 168, 76, 0.2) !important;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">
    <div style="width: 100%; max-width: 100%; margin: 0 auto; padding: 12px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background-color: #faf7f2; min-height: 100vh;">
        
        <!-- Page Header Section -->
        <div style="background: #ffffff; border-radius: 12px; padding: 12px 20px; box-shadow: 0 1px 2px rgba(0,0,0,0.05); border: 1px solid #e0d5c5; margin-bottom: 16px; display: flex; align-items: center; justify-content: space-between;">
            <div style="display: flex; align-items: center; gap: 16px;">
                <div style="width: 44px; height: 44px; background: linear-gradient(135deg, #C9A84C 0%, #8B5E3C 100%); border-radius: 10px; display: flex; align-items: center; justify-content: center; color: #ffffff; font-size: 1.3rem; box-shadow: 0 4px 6px -1px rgba(201, 168, 76, 0.1);">
                    <i class="fas fa-receipt"></i>
                </div>
                <div>
                    <h1 style="font-size: 1.25rem; font-weight: 800; color: black; margin: 0; letter-spacing: -0.01em;">Receipt Explorer</h1>
                    <p style="color: black; margin: 0; font-size: 0.85rem; font-weight: 400;">Manage membership receipts</p>
                </div>
            </div>
            <div style="display: flex; gap: 12px;">
                <div style="text-align: right;">
                    <span style="display: block; font-size: 0.75rem; font-weight: 700; color: #a09080; text-transform: uppercase;">System Status</span>
                    <span style="color: #10b981; font-size: 0.875rem; font-weight: 600; display: flex; align-items: center; gap: 6px; justify-content: flex-end;">
                        <span style="width: 8px; height: 8px; background: #10b981; border-radius: 50%;"></span> Online
                    </span>
                </div>
            </div>
        </div>

        <!-- Filter and Search Section -->
        <div style="background: #ffffff; border-radius: 10px; padding: 16px 20px; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); border: 1px solid #e0d5c5; margin-bottom: 16px;">
            <div style="margin-bottom: 16px; display: flex; align-items: center; gap: 8px;">
                <div style="width: 3px; height: 18px; background: #C9A84C; border-radius: 2px;"></div>
                <h2 style="font-size: 1rem; font-weight: 700; color: #1e293b; margin: 0;">Search Parameters</h2>
            </div>
            
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 16px;">
                <!-- Receipt Number -->
                <div style="display: flex; flex-direction: column; gap: 4px;">
                    <label style="font-size: 0.75rem; font-weight: 600; color: #8B5E3C; display: flex; align-items: center; gap: 6px;">
                        <i class="fas fa-hashtag" style="font-size: 0.65rem; color: #a09080;"></i> Receipt #
                    </label>
                    <asp:TextBox ID="txtSearchReceiptNo" runat="server" CssClass="form-input-focus" 
                        style="width: 100%; padding: 0.4rem 0.6rem; border: 1px solid #e0d5c5; border-radius: 0.4rem; font-size: 0.9rem; color: #1A1A2E; background: #ffffff; transition: all 0.2s;" 
                        placeholder="RCP-XXXX"></asp:TextBox>
                </div>

                <!-- Applicant ID -->
                <div style="display: flex; flex-direction: column; gap: 4px;">
                    <label style="font-size: 0.75rem; font-weight: 600; color: #8B5E3C; display: flex; align-items: center; gap: 6px;">
                        <i class="fas fa-user-circle" style="font-size: 0.65rem; color: #a09080;"></i> Applicant / Ref#
                    </label>
                    <asp:TextBox ID="txtSearchApplicantNo" runat="server" CssClass="form-input-focus" 
                        style="width: 100%; padding: 0.4rem 0.6rem; border: 1px solid #e0d5c5; border-radius: 0.4rem; font-size: 0.9rem; color: #1A1A2E; background: #ffffff; transition: all 0.2s;" 
                        placeholder="Identifier..."></asp:TextBox>
                </div>

                <!-- From Date -->
                <div style="display: flex; flex-direction: column; gap: 4px;">
                    <label style="font-size: 0.75rem; font-weight: 600; color: #8B5E3C; display: flex; align-items: center; gap: 6px;">
                        <i class="fas fa-calendar-day" style="font-size: 0.65rem; color: #a09080;"></i> From
                    </label>
                    <asp:TextBox ID="txtFromDate" runat="server" CssClass="form-input-focus" 
                        style="width: 100%; padding: 0.4rem 0.6rem; border: 1px solid #e0d5c5; border-radius: 0.4rem; font-size: 0.9rem; color: #1A1A2E; background: #ffffff; transition: all 0.2s;" 
                        TextMode="Date"></asp:TextBox>
                </div>

                <!-- To Date -->
                <div style="display: flex; flex-direction: column; gap: 4px;">
                    <label style="font-size: 0.75rem; font-weight: 600; color: #8B5E3C; display: flex; align-items: center; gap: 6px;">
                        <i class="fas fa-calendar-check" style="font-size: 0.65rem; color: #a09080;"></i> To
                    </label>
                    <asp:TextBox ID="txtToDate" runat="server" CssClass="form-input-focus" 
                        style="width: 100%; padding: 0.4rem 0.6rem; border: 1px solid #e0d5c5; border-radius: 0.4rem; font-size: 0.9rem; color: #1A1A2E; background: #ffffff; transition: all 0.2s;" 
                        TextMode="Date"></asp:TextBox>
                </div>
            </div>

            <!-- Action Section (Search Button) -->
            <div style="display: flex; justify-content: flex-end; padding-top: 10px; border-top: 1px solid #F7F3EE;">
                <asp:LinkButton ID="btnSearch" runat="server" CssClass="btn-premium-search" OnClick="btnSearch_Click">
                    <i class="fas fa-search"></i> Search
                </asp:LinkButton>
            </div>
        </div>

        <!-- Results Section -->
        <div style="background: #ffffff; border-radius: 10px; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); border: 1px solid #e0d5c5; overflow: hidden;">
            <div style="padding: 12px 20px; border-bottom: 1px solid #F7F3EE; display: flex; align-items: center; justify-content: space-between; background: #ffffff;">
                <h2 style="font-size: 1rem; font-weight: 700; color: #1e293b; margin: 0; display: flex; align-items: center; gap: 8px;">
                    <i class="fas fa-table" style="color: #C9A84C;"></i> Search Results
                </h2>
                <div style="display: flex; align-items: center; gap: 8px;">
                    <span style="font-size: 0.7rem; font-weight: 600; color: #7a7a7a; background: #F7F3EE; padding: 2px 10px; border-radius: 12px; border: 1px solid #e0d5c5;">
                        Membership Records
                    </span>
                </div>
            </div>
            
            <div style="overflow-x: auto;">
                <asp:GridView ID="gvResults" runat="server" AutoGenerateColumns="False" 
                    style="width: 100%; border-collapse: collapse; font-size: 0.875rem;" 
                    GridLines="None" EmptyDataText="No receipts found."
                    AllowPaging="True" PageSize="10" OnPageIndexChanging="gvResults_PageIndexChanging">
                    <PagerStyle CssClass="gv-pager-premium" HorizontalAlign="Center" />
                    <HeaderStyle BackColor="#faf7f2" Height="40px" VerticalAlign="Middle" />
                    <RowStyle CssClass="gv-row-premium" BorderStyle="None" />
                    <Columns>
                        <asp:TemplateField HeaderText="Receipt #">
                            <HeaderStyle CssClass="gv-header-text gv-header-first" />
                            <ItemStyle CssClass="gv-cell-standard gv-cell-first" />
                            <ItemTemplate>
                                <span style="display: inline-block; background: #e0e7ff; color: #3730a3; padding: 4px 10px; border-radius: 6px; font-weight: 700; font-size: 0.8rem;">
                                    <%# Eval("ReceiptNo") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Date">
                            <HeaderStyle CssClass="gv-header-text" />
                            <ItemStyle CssClass="gv-cell-standard" />
                            <ItemTemplate>
                                <div style="display: flex; align-items: center; gap: 8px; color: #8B5E3C; font-weight: 500;">
                                    <i class="far fa-calendar-alt" style="color: #a09080; font-size: 0.85rem;"></i>
                                    <%# Eval("ReceiptDate", "{0:dd MMM yyyy}") %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Applicant Info">
                            <HeaderStyle CssClass="gv-header-text" />
                            <ItemStyle CssClass="gv-cell-standard" />
                            <ItemTemplate>
                                <div style="display: flex; flex-direction: column; gap: 2px;">
                                    <span style="font-weight: 700; color: #1A1A2E; font-size: 0.95rem;"><%# Eval("ApplicantName") %></span>
                                    <span style="font-size: 0.8rem; color: #7a7a7a; display: flex; align-items: center; gap: 4px;">
                                        <i class="fas fa-id-badge" style="font-size: 0.7rem; opacity: 0.5;"></i> <%# Eval("MemberNo") %>
                                    </span>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:BoundField DataField="PaymentHeadName" HeaderText="Payment Head">
                            <HeaderStyle CssClass="gv-header-text" />
                            <ItemStyle CssClass="gv-cell-standard gv-cell-bold" />
                        </asp:BoundField>

                        <asp:TemplateField HeaderText="Mode">
                            <HeaderStyle CssClass="gv-header-text" />
                            <ItemStyle CssClass="gv-cell-standard" />
                            <ItemTemplate>
                                <span style="font-weight: 600; color: #8B5E3C; font-size: 0.85rem;"><%# Eval("ReceiptModeName") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Amount">
                            <HeaderStyle CssClass="gv-header-text gv-header-right" />
                            <ItemStyle CssClass="gv-cell-standard gv-cell-right" />
                            <ItemTemplate>
                                <div style="display: inline-flex; align-items: center; gap: 4px;">
                                    <span style="color: #059669; font-weight: 800; font-size: 0.9rem; font-family: 'JetBrains Mono', 'Consolas', monospace;">
                                        <%# Eval("TotalAmount", "{0:N2}") %>
                                    </span>
                                    <span style="font-size: 0.6rem; font-weight: 700; color: #a09080;">PKR</span>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Action">
                            <HeaderStyle CssClass="gv-header-text gv-header-center" />
                            <ItemStyle CssClass="gv-cell-standard gv-cell-center" />
                            <ItemTemplate>
                                <asp:HyperLink ID="lnkView" runat="server" 
                                    NavigateUrl='<%# "ReceiptReport.aspx?ReceiptNo=" + Eval("ReceiptNo") %>' 
                                    Target="_blank" CssClass="btn-view-report">
                                    <i class="fas fa-print"></i> Report
                                </asp:HyperLink>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="padding: 80px 40px; text-align: center; background: #ffffff;">
                            <div style="width: 80px; height: 80px; background: #faf7f2; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px;">
                                <i class="fas fa-search" style="font-size: 2rem; color: #e0d5c5;"></i>
                            </div>
                            <h3 style="font-size: 1.25rem; font-weight: 700; color: #1e293b; margin: 0 0 8px;">No Results Found</h3>
                            <p style="color: #E8D5A3; font-size: 0.95rem; max-width: 300px; margin: 0 auto;">Try adjusting your search filters to find the receipts you're looking for.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

        <!-- Footer Info -->
        <div style="margin-top: 24px; text-align: center; padding-bottom: 40px;">
            <p style="color: #a09080; font-size: 0.8rem; font-weight: 500;">
                <i class="fas fa-info-circle" style="margin-right: 4px;"></i> 
                Records are synchronized with the central database in real-time.
            </p>
        </div>

    </div>
</asp:Content>

