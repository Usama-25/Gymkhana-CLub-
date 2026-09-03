<%@ Page Title="Shortlisted Applicants Report" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true"
    CodeFile="InterviewList.aspx.cs" Inherits="Membership.Reports.InterviewList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Essential Styles (Self-contained for server deployments) */
        .table-container { background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
        .table { width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left; }
        .table th { background: #1A1A2E; color: #C9A84C; font-weight: 600; padding: 0.75rem 1rem; border-bottom: 2px solid #e0d5c5; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.05em; }
        .table td { padding: 0.75rem 1rem; border-bottom: 1px solid #e0d5c5; color: #1A1A2E; vertical-align: middle; }
        .table tr:last-child td { border-bottom: none; }
        .empty-state { padding: 2rem; text-align: center; color: #8B5E3C; background-color: #faf7f2; border: 1px dashed #e0d5c5; border-radius: 12px; display: flex; flex-direction: column; align-items: center; gap: 0.75rem; margin-top: 1rem; }
        .empty-state svg { color: #8B5E3C; opacity: 0.6; margin-bottom: 0.5rem; }
        .form-control { display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; }
        .form-control:focus { border-color: #C9A84C; box-shadow: 0 0 0 3px rgba(201, 168, 76, 0.15); outline: none; }
        
        /* Button Styles */
        .btn { display: inline-block; text-align: center; vertical-align: middle; padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: all 0.15s ease; border: 1px solid transparent; line-height: 1; text-decoration: none; }
        .btn-primary { background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2); }
        .btn-primary:hover { box-shadow: 0 8px 12px rgba(201, 168, 76, 0.3); transform: translateY(-1px); }
        .btn-secondary { background-color: white; color: #8B5E3C; border-color: #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); border: 1px solid #e0d5c5; }
        .btn-secondary:hover { background-color: #F7F3EE; border-color: #e0d5c5; color: #1A1A2E; }

        /* Report Header - Hidden on screen, visible only on print */
        .report-header {
            display: none !important;
        }

        @media print {
            .report-header {
                display: block !important;
                text-align: center !important;
                margin-bottom: 25px !important;
                padding-bottom: 15px !important;
                border-bottom: 2px solid #2c5282 !important;
            }
            .report-logo {
                width: 100px !important;
                height: 100px !important;
                margin-bottom: 10px !important;
                display: inline-block !important;
            }
            .report-title {
                font-size: 20px !important;
                font-weight: bold !important;
                color: #1a365d !important;
                margin-bottom: 5px !important;
                display: block !important;
            }
            .report-date {
                font-size: 11px !important;
                color: #718096 !important;
                margin-top: 5px !important;
                display: block !important;
            }
            /* Hide filter controls and buttons when printing the whole page */
            .flex, [id*="btnExport"], [id*="btnPrintPDF"], [id*="btnGenerate"], [id*="ddlType"], [id*="txtFromDate"], [id*="txtToDate"], label, .page-wrapper {
                margin: 0 !important;
                border: none !important;
                box-shadow: none !important;
            }
            .page-wrapper > .card {
                border: none !important;
                box-shadow: none !important;
                padding: 0 !important;
            }
            aside, header, #appSidebar, .no-print, [style*="background: #faf7f2"] {
                display: none !important;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-wrapper mt-6" style="margin-top: 0.75rem;">
        <div class="card" style="background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); position: relative; overflow: hidden; height: 100%;">
            
            <!-- Printable Report Header -->
            <div class="report-header">
                <img src='<%= ResolveUrl("~/MemberShipModule/assets/images/report_logo.png") %>' alt="Club Logo"
                    class="report-logo" />
                <h1 class="report-title">Lahore Gymkhana Club</h1>
                <h2 class="report-title">
                    <%: Page.Title %>
                </h2>
                <p class="report-date">Generated on: <%= DateTime.Now.ToString("dd-MMM-yyyy HH:mm") %>
                </p>
            </div>

            <!-- Screen Header Section -->
            <div class="flex items-center justify-between mb-8 pb-6 border-b border-subtle" style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 2rem; padding-bottom: 1.5rem; border-bottom: 1px solid #e0d5c5; border-color: #e0d5c5 !important;">
                <div>
                    <h1 style="font-size: 1.5rem; font-weight: 700; color: #1A1A2E; margin: 0;">Shortlisted Applicants</h1>
                    <p style="color: #8B5E3C; margin: 0.25rem 0 0 0; font-size: 0.95rem;">Managing and searching all candidates shortlisted for interview</p>
                </div>
                <div style="display: flex; gap: 0.75rem;">
                    <asp:LinkButton ID="btnExport" runat="server" OnClick="btnExport_Click" CssClass="btn btn-secondary">
                        <i class="fas fa-file-excel mr-2" style="color: #16a34a;"></i> Export to Excel
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnPrintPDF" runat="server" OnClick="btnPrintPDF_Click" CssClass="btn btn-primary" style="color: white;">
                        <i class="fas fa-print"></i> Print Report
                    </asp:LinkButton>
                </div>
            </div>

            <!-- Filter Panel -->
            <div style="background: #faf7f2; padding: 1.5rem; border-radius: 8px; border: 1px solid #e0d5c5; margin-bottom: 2rem;">
                <div style="display: flex; flex-wrap: wrap; gap: 1.5rem; align-items: flex-end;">
                    <div style="flex: 2; min-width: 250px;">
                        <label style="display: block; font-size: 0.875rem; font-weight: 600; color: #1A1A2E; margin-bottom: 0.5rem;">Membership Type</label>
                        <asp:DropDownList ID="ddlType" runat="server" CssClass="form-control" style="height: 38px;">
                            <asp:ListItem Text="All Membership Types" Value=""></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div style="flex: 1; min-width: 200px;">
                        <label style="display: block; font-size: 0.875rem; font-weight: 600; color: #1A1A2E; margin-bottom: 0.5rem;">Date From</label>
                        <asp:TextBox ID="txtFromDate" runat="server" TextMode="Date" CssClass="form-control" style="height: 38px;" />
                    </div>
                    <div style="flex: 1; min-width: 200px;">
                        <label style="display: block; font-size: 0.875rem; font-weight: 600; color: #1A1A2E; margin-bottom: 0.5rem;">Date To</label>
                        <asp:TextBox ID="txtToDate" runat="server" TextMode="Date" CssClass="form-control" style="height: 38px;" />
                    </div>
                    <div>
                        <asp:Button ID="btnGenerate" runat="server" Text="Apply Filters" OnClick="btnGenerate_Click" CssClass="btn btn-primary" style="height: 38px; padding: 0 1.5rem;" />
                    </div>
                </div>
            </div>

            <!-- Results Grid -->
            <div class="table-container mb-6">
                <asp:GridView ID="gvInterviewList" runat="server" AutoGenerateColumns="False"
                    GridLines="None" Width="100%" CssClass="table table-bordered table-hover"
                    EmptyDataText="No shortlisted candidates found for the selected criteria."
                    style="border-collapse: collapse;">
                    <Columns>
                        <asp:TemplateField HeaderText="S. NO." ItemStyle-Width="5%">
                            <ItemTemplate>
                                <div style="font-weight: 500; color: #1A1A2E; text-align: center;">
                                    <%# string.Format("{0:00}", Container.DataItemIndex + 1) %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="NAME" ItemStyle-Width="18%">
                            <ItemTemplate>
                                <div style="font-weight: 600; color: #1A1A2E;">
                                    <%# Eval("ApplicantName") %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="PROFESSION / STATUS" ItemStyle-Width="22%">
                            <ItemTemplate>
                                <div style="font-weight: 500; color: #1A1A2E;">
                                    <%# Eval("Profession") %>
                                </div>
                                <div style="font-size: 0.825rem; color: #64748b; margin-top: 2px; line-height: 1.2;">
                                    <%# (Eval("CompanyName") != DBNull.Value && Eval("CompanyName").ToString() != "" && Eval("CompanyName").ToString() != ".") 
                                            ? Eval("CompanyName").ToString() + ((Eval("Designation") != DBNull.Value && Eval("Designation").ToString() != "" && Eval("Designation").ToString() != ".") ? " (" + Eval("Designation").ToString() + ")" : "") 
                                            : ((Eval("Designation") != DBNull.Value && Eval("Designation").ToString() != "" && Eval("Designation").ToString() != ".") ? Eval("Designation").ToString() : "") %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="INCOME" ItemStyle-Width="10%">
                            <ItemTemplate>
                                <div style="color: #1A1A2E;">
                                    <%# Eval("MonthlyIncome") != DBNull.Value && Convert.ToDecimal(Eval("MonthlyIncome")) > 0 
                                            ? Convert.ToDecimal(Eval("MonthlyIncome")).ToString("#,##0") + "/-" 
                                            : "00/-" %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="PROPOSER" ItemStyle-Width="16%">
                            <ItemTemplate>
                                <div style="color: #1A1A2E; font-weight: 500;"><%# Eval("ProposerName") %></div>
                                <div style="font-size: 0.825rem; color: #64748b; margin-top: 2px;"><%# Eval("ProposerMemberNo") != DBNull.Value && Eval("ProposerMemberNo").ToString() != "" ? "(" + Eval("ProposerMemberNo").ToString() + ")" : "" %></div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="SECONDER" ItemStyle-Width="16%">
                            <ItemTemplate>
                                <div style="color: #1A1A2E; font-weight: 500;"><%# Eval("SeconderName") %></div>
                                <div style="font-size: 0.825rem; color: #64748b; margin-top: 2px;"><%# Eval("SeconderMemberNo") != DBNull.Value && Eval("SeconderMemberNo").ToString() != "" ? "(" + Eval("SeconderMemberNo").ToString() + ")" : "" %></div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="AMOUNT DEPOSITED" ItemStyle-Width="10%">
                            <ItemTemplate>
                                <div style="font-weight: 500; color: #1A1A2E;">
                                    <%# Eval("MFee") != DBNull.Value && Convert.ToDecimal(Eval("MFee")) > 0 
                                            ? Convert.ToDecimal(Eval("MFee")).ToString("#,##0") + "/-" 
                                            : "00/-" %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="DATE OF APPL." ItemStyle-Width="8%">
                            <ItemTemplate>
                                <div style="color: #8B5E3C;"><%# Eval("CreatedAt", "{0:dd-MM-yyyy}") %></div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="empty-state">
                            <i class="fas fa-search" style="font-size: 3rem; margin-bottom: 1rem; opacity: 0.5;"></i>
                            <h3 style="margin: 0; font-size: 1.25rem; font-weight: 600;">No Candidates Found</h3>
                            <p style="margin-top: 0.5rem;">No shortlisted applicants matching your criteria were found.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>

        </div>
    </div>
</asp:Content>
