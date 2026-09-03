<%@ Page Title="New Applications Report" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true"
    CodeFile="NewApplications.aspx.cs" Inherits="Membership.Reports.NewApplications" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <!-- Keep Fonts but move styling inline as requested -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div style="width: 100%; margin: 0 auto; padding: 1.5rem; font-family: 'Inter', sans-serif; box-sizing: border-box;">
        
        <!-- Header Section -->
        <div style="background: white; border-radius: 16px; padding: 2rem; margin-bottom: 2rem; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); display: flex; justify-content: space-between; align-items: center;">
            <div>
                <h1 style="font-size: 1.875rem; font-weight: 700; color: #1A1A2E; margin: 0; letter-spacing: -0.025em;">New Applications</h1>
                <p style="color: #8B5E3C; margin: 0.5rem 0 0 0; font-size: 1rem;">Managing and searching all pending membership applications</p>
            </div>
            <div style="display: flex; gap: 0.75rem;">
                <asp:LinkButton ID="btnExport" runat="server" OnClick="btnExport_Click"
                    style="display: none; align-items: center; justify-content: center; padding: 0.625rem 1.25rem; border-radius: 8px; font-weight: 600; font-size: 0.95rem; cursor: pointer; border: 1px solid #e0d5c5; background: white; color: #1A1A2E; text-decoration: none; gap: 0.5rem;">
                    <i class="fas fa-file-excel" style="color: #16a34a;"></i> Excel
                </asp:LinkButton>
                <asp:LinkButton ID="btnPrintPDF" runat="server" OnClick="btnPrintPDF_Click"
                    style="display: inline-flex; align-items: center; justify-content: center; padding: 0.625rem 1.25rem; border-radius: 8px; font-weight: 600; font-size: 0.95rem; cursor: pointer; border: 1px solid transparent; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; text-decoration: none; gap: 0.5rem;">
                    <i class="fas fa-print"></i> Print Report
                </asp:LinkButton>
            </div>
        </div>

        <!-- Summary Stats -->
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 1.5rem; margin-bottom: 2rem;">
            <!-- Stat 1 -->
            <div style="background: white; padding: 1.5rem; border-radius: 16px; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); display: flex; align-items: center; gap: 1rem;">
                <div style="width: 48px; height: 48px; border-radius: 12px; background: #f5ecd5; color: #C9A84C; border: 1px solid #f5ecd5; display: flex; align-items: center; justify-content: center; font-size: 1.25rem;">
                    <i class="fas fa-file-alt"></i>
                </div>
                <div>
                    <h4 style="margin: 0; font-size: 0.875rem; color: #8B5E3C; font-weight: 500;">Pending Applications</h4>
                    <span style="font-size: 1.5rem; font-weight: 700; color: #1A1A2E;"><asp:Literal ID="litTotalAdmissions" runat="server">0</asp:Literal></span>
                </div>
            </div>
            <!-- Stat 2 -->
            <div style="background: white; padding: 1.5rem; border-radius: 16px; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); display: flex; align-items: center; gap: 1rem;">
                <div style="width: 48px; height: 48px; border-radius: 12px; background: #faf7f2; color: #8B5E3C; border: 1px solid #e0d5c5; display: flex; align-items: center; justify-content: center; font-size: 1.25rem;">
                    <i class="fas fa-calendar-alt"></i>
                </div>
                <div>
                    <h4 style="margin: 0; font-size: 0.875rem; color: #8B5E3C; font-weight: 500;">Filter Period</h4>
                    <span style="font-size: 1rem; font-weight: 600; color: #1A1A2E;"><asp:Literal ID="litPeriod" runat="server">All Pending</asp:Literal></span>
                </div>
            </div>
            <!-- Stat 3 -->
            <div style="background: white; padding: 1.5rem; border-radius: 16px; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); display: flex; align-items: center; gap: 1rem;">
                <div style="width: 48px; height: 48px; border-radius: 12px; background: #faf7f2; color: #C9A84C; border: 1px solid #e0d5c5; display: flex; align-items: center; justify-content: center; font-size: 1.25rem;">
                    <i class="fas fa-user-clock"></i>
                </div>
                <div>
                    <h4 style="margin: 0; font-size: 0.875rem; color: #8B5E3C; font-weight: 500;">Waitlist Status</h4>
                    <span style="font-size: 1.5rem; font-weight: 700; color: #1A1A2E;">Active</span>
                </div>
            </div>
        </div>

        <!-- Filter Panel -->
        <div style="background: white; padding: 1.5rem; border-radius: 16px; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); margin-bottom: 2rem;">
            <div style="display: flex; flex-wrap: wrap; gap: 1.5rem; align-items: flex-end;">
                <div style="flex: 1; min-width: 200px;">
                    <label style="display: block; font-size: 0.875rem; font-weight: 600; color: #1A1A2E; margin-bottom: 0.5rem;">Application From</label>
                    <asp:TextBox ID="txtFromDate" runat="server" TextMode="Date" 
                        style="width: 100%; height: 42px; padding: 0.5rem 1rem; border-radius: 8px; border: 1px solid #e0d5c5; font-size: 0.95rem;" />
                </div>
                <div style="flex: 1; min-width: 200px;">
                    <label style="display: block; font-size: 0.875rem; font-weight: 600; color: #1A1A2E; margin-bottom: 0.5rem;">Application To</label>
                    <asp:TextBox ID="txtToDate" runat="server" TextMode="Date" 
                        style="width: 100%; height: 42px; padding: 0.5rem 1rem; border-radius: 8px; border: 1px solid #e0d5c5; font-size: 0.95rem;" />
                </div>
                <div>
                    <asp:Button ID="btnFilter" runat="server" Text="Apply Filter" OnClick="btnFilter_Click" 
                        style="height: 42px; padding: 0 1.5rem; border-radius: 8px; font-weight: 600; font-size: 0.95rem; cursor: pointer; border: none; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white;" />
                </div>
            </div>
        </div>

        <!-- Results Table -->
        <div style="background: white; border-radius: 16px; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); overflow: hidden;">
            <asp:GridView ID="gvApplications" runat="server" AutoGenerateColumns="False"
                GridLines="None" Width="100%"
                OnRowDataBound="gvApplications_RowDataBound"
                EmptyDataText="No pending applications found for the selected criteria."
                style="border-collapse: collapse;">
                <HeaderStyle BackColor="#1A1A2E" Font-Bold="True" ForeColor="#C9A84C" 
                    Height="48px" HorizontalAlign="Left" />
                <RowStyle Height="52px" BorderColor="#e0d5c5" BorderStyle="Solid" BorderWidth="1px" />
                <AlternatingRowStyle BackColor="#faf7f2" />
                <Columns>
                    <asp:TemplateField>
                        <HeaderTemplate>
                            <div style="padding: 16px; font-weight: 700; color: #8B5E3C; text-transform: uppercase; font-size: 0.75rem;">ID</div>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding: 16px;">
                                <span style="font-weight: 700; color: #C9A84C; font-family: 'JetBrains Mono', monospace;"><%# Eval("ApplicantID") %></span>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField>
                        <HeaderTemplate>
                            <div style="padding: 16px; font-weight: 700; color: #8B5E3C; text-transform: uppercase; font-size: 0.75rem;">Applicant Name</div>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding: 16px; font-weight: 500; color: #1A1A2E;">
                                <%# Eval("ApplicantName") %><br/>
                                <small style="color: #8B5E3C;">S/O: <%# Eval("FatherName") %></small>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField>
                        <HeaderTemplate>
                            <div style="padding: 16px; font-weight: 700; color: #8B5E3C; text-transform: uppercase; font-size: 0.75rem;">Category / Class</div>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding: 16px;">
                                <div><%# Eval("MembershipType") %></div>
                                <div style="font-size: 0.8rem; color: #8B5E3C;"><%# Eval("Membership_class") %></div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField>
                        <HeaderTemplate>
                            <div style="padding: 16px; font-weight: 700; color: #8B5E3C; text-transform: uppercase; font-size: 0.75rem;">Submission Date</div>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding: 16px;"><%# Eval("CreatedOn", "{0:dd MMM yyyy}") %></div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField>
                        <HeaderTemplate>
                            <div style="padding: 16px; font-weight: 700; color: #8B5E3C; text-transform: uppercase; font-size: 0.75rem;">Status</div>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding: 16px;">
                                <asp:Literal ID="litStatus" runat="server"></asp:Literal>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div style="padding: 4rem 2rem; text-align: center; color: #8B5E3C;">
                        <i class="fas fa-search" style="font-size: 3rem; margin-bottom: 1rem; opacity: 0.5;"></i>
                        <h3 style="margin: 0; font-size: 1.25rem; font-weight: 600;">No Pending Applications</h3>
                        <p style="margin-top: 0.5rem;">There are no applications matching your criteria.</p>
                    </div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
