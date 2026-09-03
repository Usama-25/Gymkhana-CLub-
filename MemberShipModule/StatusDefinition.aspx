<%@ Page Title="Status Definition" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true" CodeFile="StatusDefinition.aspx.cs" Inherits="MemberShipModule_StatusDefinition" %>

<asp:Content ID="HeadStyles" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .page-wrapper { margin-top: 0.75rem; }
        .card { background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
        .section-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 2rem; padding-bottom: 1.5rem; border-bottom: 1px solid #e2e8f0; }
        .section-title { font-size: 1.5rem; font-weight: 700; color: #0f172a; margin: 0; }
        .section-subtitle { color: #475569; margin-top: 0.25rem; }
        .content-section { margin-bottom: 2rem; padding: 1.5rem; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; }
        .content-section h3 { font-size: 1.25rem; font-weight: 600; color: #1e293b; margin-top: 0; margin-bottom: 1rem; }
        
        .form-group { margin-bottom: 1rem; }
        .form-label { display: block; font-weight: 500; margin-bottom: 0.5rem; color: #334155; }
        .form-control { width: 100%; padding: 0.5rem; border: 1px solid #cbd5e1; border-radius: 6px; }
        .btn { padding: 0.5rem 1rem; border-radius: 6px; border: none; cursor: pointer; color: white; font-weight: 600; }
        .btn-primary { background-color: #2563eb; }
        
        .table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
        .table th { background: #f1f5f9; padding: 0.75rem; text-align: left; border-bottom: 2px solid #e2e8f0; }
        .table td { padding: 0.75rem; border-bottom: 1px solid #e2e8f0; }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="Server">
    <div class="page-wrapper">
        <div class="card">
            <div class="section-header">
                <div>
                    <h1 class="section-title">Status Definition</h1>
                    <p class="section-subtitle">Manage Membership and Residential Statuses</p>
                </div>
            </div>

            <asp:UpdatePanel ID="upStatuses" runat="server">
                <ContentTemplate>
                    <asp:Label ID="lblMessage" runat="server" ForeColor="Green" Visible="false" CssClass="form-group" style="display:block;"></asp:Label>
                    
                    <div style="display: flex; gap: 2rem; width: 100%;">
                        <div class="content-section" style="flex: 1; width: 50%; margin-bottom: 0; display: flex; flex-direction: column;">
                        <h3>Membership Status</h3>
                        <div class="form-group" style="display: flex; gap: 1rem; align-items: end;">
                            <div>
                                <label class="form-label">New Membership Status</label>
                                <asp:TextBox ID="txtNewMembershipStatus" runat="server" CssClass="form-control" Width="250px" style="width: 100% !important; max-width: 250px !important; padding: 0.6rem 0.75rem !important; border: 1px solid #cbd5e1 !important; border-radius: 6px !important; outline: none !important; font-size: 0.95rem !important; color: #0f172a !important; background-color: #ffffff !important; box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.05) !important;"></asp:TextBox>
                            </div>
                            <asp:Button ID="btnAddMembershipStatus" runat="server" Text="Add" CssClass="btn btn-primary" OnClick="btnAddMembershipStatus_Click" style="background-color: #2563eb !important; color: white !important; padding: 0.5rem 1.25rem !important; border-radius: 6px !important; border: none !important; cursor: pointer !important; font-weight: 600 !important; font-size: 0.95rem !important; box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2) !important;" />
                        </div>
                        
                        <asp:GridView ID="gvMembershipStatus" runat="server" AutoGenerateColumns="False" CssClass="table" DataKeyNames="TypeID" OnRowDeleting="gvMembershipStatus_RowDeleting" GridLines="None">
                            <Columns>
                                <asp:BoundField DataField="TypeID" HeaderText="Type ID" ReadOnly="True" />
                                <asp:BoundField DataField="TypeName" HeaderText="Type Name" />
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnDeleteMembership" runat="server" CommandName="Delete" Text="Delete" OnClientClick="return confirm('Are you sure you want to delete this status?');"
                                            style="background-color: #ef4444 !important; color: white !important; padding: 0.35rem 0.75rem !important; border-radius: 6px !important; border: none !important; cursor: pointer !important; font-weight: 600 !important; font-size: 0.875rem !important; text-decoration: none !important; display: inline-block !important;"></asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>No membership statuses defined.</EmptyDataTemplate>
                        </asp:GridView>
                    </div>

                    <div class="content-section" style="flex: 1; width: 50%; margin-bottom: 0; display: flex; flex-direction: column;">
                        <h3>Residential Status</h3>
                        <div class="form-group" style="display: flex; gap: 1rem; align-items: end;">
                            <div>
                                <label class="form-label">New Residential Status</label>
                                <asp:TextBox ID="txtNewResidentialStatus" runat="server" CssClass="form-control" Width="250px" style="width: 100% !important; max-width: 250px !important; padding: 0.6rem 0.75rem !important; border: 1px solid #cbd5e1 !important; border-radius: 6px !important; outline: none !important; font-size: 0.95rem !important; color: #0f172a !important; background-color: #ffffff !important; box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.05) !important;"></asp:TextBox>
                            </div>
                            <asp:Button ID="btnAddResidentialStatus" runat="server" Text="Add" CssClass="btn btn-primary" OnClick="btnAddResidentialStatus_Click" style="background-color: #2563eb !important; color: white !important; padding: 0.5rem 1.25rem !important; border-radius: 6px !important; border: none !important; cursor: pointer !important; font-weight: 600 !important; font-size: 0.95rem !important; box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2) !important;" />
                        </div>

                        <asp:GridView ID="gvResidentialStatus" runat="server" AutoGenerateColumns="False" CssClass="table" DataKeyNames="TypeID" OnRowDeleting="gvResidentialStatus_RowDeleting" GridLines="None">
                            <Columns>
                                <asp:BoundField DataField="TypeID" HeaderText="Type ID" ReadOnly="True" />
                                <asp:BoundField DataField="Status" HeaderText="Type Name" />
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnDeleteResidential" runat="server" CommandName="Delete" Text="Delete" OnClientClick="return confirm('Are you sure you want to delete this status?');"
                                            style="background-color: #ef4444 !important; color: white !important; padding: 0.35rem 0.75rem !important; border-radius: 6px !important; border: none !important; cursor: pointer !important; font-weight: 600 !important; font-size: 0.875rem !important; text-decoration: none !important; display: inline-block !important;"></asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>No residential statuses defined.</EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>
</asp:Content>
