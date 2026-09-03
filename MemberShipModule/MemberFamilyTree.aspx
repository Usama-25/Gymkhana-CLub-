<%@ Page Title="Member Family Tree" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true"
    CodeFile="MemberFamilyTree.aspx.cs" Inherits="ApplicationProcessing" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <style>
            body { font-family: 'Outfit', sans-serif !important; background-color: #faf7f2; }
            /* Essential Styles (Self-contained for server deployments) */
            .table-container { background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
            .table { width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left; }
            .table th { background: #1A1A2E; color: #C9A84C; font-weight: 600; padding: 0.75rem 1rem; border-bottom: 2px solid #e0d5c5; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.05em; }
            .table td { padding: 0.75rem 1rem; border-bottom: 1px solid #e0d5c5; color: #1A1A2E; vertical-align: middle; }
            .table tr:last-child td { border-bottom: none; }
            .empty-state { padding: 2rem; text-align: center; color: #a09080; background-color: #faf7f2; border: 1px dashed #e0d5c5; border-radius: 12px; display: flex; flex-direction: column; align-items: center; gap: 0.75rem; margin-top: 1rem; }
            .empty-state svg { color: #a09080; opacity: 0.6; margin-bottom: 0.5rem; }
            .table-input { width: 100%; padding: 0.5rem 0.75rem; border: 1px solid transparent; border-radius: 6px; background: transparent; font-size: 0.95rem; color: #1A1A2E; transition: all 0.2s ease; }
            .table-input:hover { background: #F7F3EE; border-color: #e0d5c5; }
            .table-input:focus { background: #ffffff; border-color: #8B5E3C; box-shadow: 0 0 0 2px #f5ecd5; outline: none; }
            .form-control { display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; }
            .form-control:focus { border-color: #C9A84C; box-shadow: 0 0 0 3px rgba(201, 168, 76, 0.15); outline: none; }
            
            /* Button Styles */
            .btn { display: inline-block; text-align: center; vertical-align: middle; padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: all 0.15s ease; border: 1px solid transparent; line-height: 1; }
            .btn-primary { background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2); }
            .btn-primary:hover { box-shadow: 0 8px 12px rgba(201, 168, 76, 0.3); transform: translateY(-1px); }
            .btn-secondary { background-color: white; color: #1A1A2E; border-color: #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
            .btn-secondary:hover { background-color: #F7F3EE; border-color: #e0d5c5; color: #1A1A2E; }
            .btn-success { background-color: #10b981; color: white; border-color: #10b981; border: 1px solid #10b981; }
            .btn-danger { background-color: #ef4444; color: white; border-color: #ef4444; border: 1px solid #ef4444; }
            .btn-warning { background-color: #f59e0b; color: white; border-color: #f59e0b; border: 1px solid #f59e0b; }
            .btn-info { background-color: #8B5E3C; color: white; border-color: #8B5E3C; border: 1px solid #8B5E3C; }
            .btn-sm { padding: 0.4rem 0.8rem; font-size: 0.875rem; }
            .btn-sm.flex { display: inline-flex; align-items: center; justify-content: center; }

            /* Tree Node Styling */
            .tree-node {
                position: relative;
                padding-left: 20px;
                margin-bottom: 12px;
            }

            .tree-node::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                width: 2px;
                height: 100%;
                background-color: #e0d5c5;
                /* Slate-300 */
            }

            .tree-node:last-child::before {
                height: 24px;
                /* Stop line for last item */
            }

            .tree-connector {
                position: absolute;
                top: 24px;
                left: 0;
                width: 16px;
                height: 2px;
                background-color: #e0d5c5;
            }

            .tree-content {
                background: #fff;
                border: 1px solid #e0d5c5;
                border-radius: 8px;
                padding: 12px 16px;
                display: flex;
                align-items: center;
                gap: 12px;
                transition: all 0.2s;
            }

            .tree-content:hover {
                border-color: #a09080;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            }

            /* Hierarchy Indentation */
            .level-1 {
                margin-left: 0;
            }

            .level-2 {
                margin-left: 40px;
            }

            .level-3 {
                margin-left: 80px;
            }

            /* Role Badges */
            .role-badge {
                font-size: 0.7rem;
                text-transform: uppercase;
                font-weight: 700;
                letter-spacing: 0.05em;
                padding: 2px 8px;
                border-radius: 4px;
            }

            /* Graphical Tree Styling */
            .graph-container {
                background: white;
                border: 1px solid #e0d5c5;
                border-radius: 12px;
                padding: 20px;
                margin-top: 20px;
                overflow: auto;
                min-height: 400px;
                display: flex;
                justify-content: center;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            }

            .graph-title {
                font-size: 1.1rem;
                font-weight: 600;
                color: #1e293b;
                margin-bottom: 12px;
                display: flex;
                align-items: center;
                gap: 8px;
            }
        </style>
        <script type="module">
            import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
            mermaid.initialize({ startOnLoad: true, theme: 'neutral' });
            window.renderMermaid = function() {
                mermaid.run();
            };
        </script>
    </asp:Content>

    <asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="Server">
        <div class="page-wrapper" style="padding: 1.5rem; width: 100%; max-width: 100%; margin: 0 auto; font-family: 'Outfit', sans-serif;">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; height: 100%;">

                <div class="card-header" style="padding: 16px 26px; border-bottom: 1px solid #e0d5c5; background: linear-gradient(135deg, #1A1A2E, #2d2d5e); display: flex; align-items: center; justify-content: space-between; margin-bottom: 1.5rem;">
                    <div>
                        <h1 style="font-size: 1.5rem; font-weight: 700; color: #fff; margin: 0;">Member Family Tree</h1>
                        <p style="color: #E8D5A3; font-size: 0.95rem; margin: 0.25rem 0 0 0;">View family hierarchy and relationships</p>
                    </div>
                </div>

                <div style="padding: 0 1.5rem 1.5rem 1.5rem;">

                <!-- Search Section -->
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-bottom: 1.5rem; background: #faf7f2; padding: 1rem; border-radius: 8px; border: 1px solid #e0d5c5;">
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Member No</label>
                        <asp:TextBox ID="txtMemberNo" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" placeholder="e.g. 1001" />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Member Name</label>
                        <asp:TextBox ID="txtMemberName" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" placeholder="Name" />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Spouse Name</label>
                        <asp:TextBox ID="txtSpouseName" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" placeholder="Spouse Name" />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">CNIC</label>
                        <asp:TextBox ID="txtCNIC" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" placeholder="xxxxx-xxxxxxx-x" MaxLength="15" />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Child Name</label>
                        <asp:TextBox ID="txtChildName" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" placeholder="Child Name" />
                    </div>
                    <div style="display: flex; gap: 0.5rem; align-items: end;">
                        <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="BtnSearch_Click" style="flex: 1; padding: 0.6rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; border: none; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);" />
                    </div>
                </div>

                <!-- Results Section -->
                <div class="space-y-8">
                    <asp:Repeater ID="rptMembers" runat="server" OnItemDataBound="rptMembers_ItemDataBound">
                        <ItemTemplate>
                            <div
                                class="border border-subtle rounded-xl overflow-hidden bg-white shadow-sm hover:shadow-md transition-shadow" style="border-color: #e0d5c5 !important;">
                                <!-- Family Header -->
                                <div
                                    class="px-6 py-4 flex justify-between items-center" style="padding: 16px 26px; border-bottom: 1px solid #e0d5c5; background: linear-gradient(135deg, #1A1A2E, #2d2d5e); display: flex; justify-content: space-between; align-items: center;">
                                    <div>
                                        <h3 class="text-lg font-bold m-0" style="font-weight: 700; color: #ffffff !important; margin: 0; font-size: 1.2rem;">Family of <%# Eval("membername") %></h3>
                                        <span class="text-sm" style="font-size: 0.875rem; line-height: 1.25rem; color: #E8D5A3 !important;">Member ID: <span class="font-mono" style="font-weight: 700; color: #E8D5A3;"><%# Eval("memberno") %></span></span>
                                    </div>
                                    <div class="text-xs font-bold px-3 py-1 rounded-full" style="font-weight: 700; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: #ffffff; padding: 4px 12px; border-radius: 99px; font-size: 0.75rem; text-transform: uppercase;">
                                        Primary Member
                                    </div>
                                </div>

                                <div class="p-6 bg-slate-50 min-h-[200px]" style="padding: 1.5rem; background-color: #faf7f2;">
                                    <!-- LEVEL 1: HEAD OF FAMILY -->
                                    <div class="level-1 mb-4 relative" style="margin-bottom: 1rem;">
                                        <div class="tree-content" style="border-left: 4px solid #1A1A2E !important;">
                                            <div
                                                style="align-items: center; justify-content: center; display: flex; background: #faf7f2; color: #1A1A2E; border: 1px solid #e0d5c5; border-radius: 50%; width: 40px; height: 40px; flex-shrink: 0;">
                                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
                                                    stroke="currentColor" stroke-width="2">
                                                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                                    <circle cx="12" cy="7" r="4"></circle>
                                                </svg>
                                            </div>
                                            <div class="flex-1" style="flex: 1;">
                                                <div class="flex items-center gap-2 mb-1" style="align-items: center; gap: 0.5rem; display: flex;">
                                                    <h4 class="font-bold text-gray-900 m-0 text-base" style="font-weight: 700; margin: 0; color: #1A1A2E;">
                                                        <%# Eval("membername") %>
                                                    </h4>
                                                    <span class="role-badge" style="background: #faf7f2; color: #1A1A2E; border: 1px solid #e0d5c5; font-size: 0.7rem; font-weight: 700; padding: 2px 8px; border-radius: 4px; text-transform: uppercase; letter-spacing: 0.05em;">Head</span>
                                                </div>
                                                <div class="text-sm text-gray-500 grid grid-cols-2 gap-4 max-w-md" style="font-size: 0.875rem; line-height: 1.25rem; color: #8B5E3C !important; gap: 1rem;">
                                                    <span>CNIC: <%# Eval("nic") %></span>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Connecting Line to Next Level -->
                                        <div class="absolute left-6 top-10 w-[2px] h-12 bg-slate-300 -z-10" style="background-color: #e0d5c5;"></div>
                                    </div>

                                    <!-- LEVEL 2: SPOUSE -->
                                    <div class="level-2 mb-4 relative" style="margin-bottom: 1rem;">
                                        <div class="tree-connector absolute -left-6 top-6 w-6 h-[2px] bg-slate-300" style="background-color: #e0d5c5;">
                                        </div>

                                        <div class="tree-content" style="border-left: 4px solid #C9A84C !important;">
                                            <div
                                                style="align-items: center; justify-content: center; display: flex; background: #f5ecd5; color: #C9A84C; border: 1px solid #e0d5c5; border-radius: 50%; width: 40px; height: 40px; flex-shrink: 0;">
                                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
                                                    stroke="currentColor" stroke-width="2">
                                                    <path
                                                        d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z">
                                                    </path>
                                                </svg>
                                            </div>
                                            <div class="flex-1" style="flex: 1;">
                                                <div class="flex items-center gap-2 mb-1" style="align-items: center; gap: 0.5rem; display: flex;">
                                                    <h4 class="font-bold text-gray-900 m-0 text-base" style="font-weight: 700; margin: 0; color: #1A1A2E;">
                                                        <%# Eval("spousename") %>
                                                    </h4>
                                                    <span class="role-badge" style="background: #f5ecd5; color: #8B5E3C; border: 1px solid #e0d5c5; font-size: 0.7rem; font-weight: 700; padding: 2px 8px; border-radius: 4px; text-transform: uppercase; letter-spacing: 0.05em;">Spouse</span>
                                                </div>
                                                <div class="text-sm text-gray-500" style="font-size: 0.875rem; line-height: 1.25rem;">
                                                    <%-- Placeholder for spouse details if any --%>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Connecting Line to Children -->
                                        <div class="absolute left-6 top-10 w-[2px] h-full bg-slate-300 -z-10 pb-4" style="padding-bottom: 1rem !important; background-color: #e0d5c5;">
                                        </div>
                                    </div>

                                    <!-- LEVEL 3: CHILDREN -->
                                    <asp:HiddenField ID="hfMID" runat="server" Value='<%# Eval("M_ID") %>' />
                                    <div class="level-3 space-y-3">
                                        <asp:Repeater ID="rptFamilyList" runat="server">
                                            <ItemTemplate>
                                                <div class="relative">
                                                    <div
                                                        class="tree-connector absolute -left-6 top-6 w-6 h-[2px] bg-slate-300" style="background-color: #e0d5c5;">
                                                    </div>
                                                    <div class="tree-content" style="border-left: 4px solid #8B5E3C !important;">
                                                        <div
                                                            style="align-items: center; justify-content: center; display: flex; background: #faf7f2; color: #8B5E3C; border: 1px solid #e0d5c5; border-radius: 50%; width: 40px; height: 40px; flex-shrink: 0;">
                                                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
                                                                stroke="currentColor" stroke-width="2">
                                                                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2">
                                                                </path>
                                                                <circle cx="9" cy="7" r="4"></circle>
                                                                <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                                                                <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                                                            </svg>
                                                        </div>
                                                        <div class="flex-1" style="flex: 1;">
                                                            <div class="flex items-center gap-2 mb-1" style="align-items: center; gap: 0.5rem; display: flex;">
                                                                <h4 class="font-bold text-gray-900 m-0 text-base" style="font-weight: 700; margin: 0; color: #1A1A2E;">
                                                                    <%# Eval("childname") %>
                                                                </h4>
                                                                <span class="role-badge" style="background: #faf7f2; color: #8B5E3C; border: 1px solid #e0d5c5; font-size: 0.7rem; font-weight: 700; padding: 2px 8px; border-radius: 4px; text-transform: uppercase; letter-spacing: 0.05em;">
                                                                    <%# Eval("Relationship") %>
                                                                </span>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <!-- Vertical line extension for siblings -->
                                                    <div
                                                        class="absolute -left-[26px] -top-4 w-[2px] h-[calc(100%+16px)] -z-10 last:h-10" style="background-color: #e0d5c5;">
                                                    </div>
                                                </div>
                                            </ItemTemplate>
                                        </asp:Repeater>

                                        <asp:Label ID="lblNoChildren" runat="server" Text="No children records found"
                                            Visible="false"
                                            CssClass="text-gray-400 italic text-sm ml-4 relative top-2"  style="font-size: 0.875rem; line-height: 1.25rem;" />
                                    </div>

                                    <!-- Graphical View Inside Family card -->
                                    <div class="mt-8 pt-6 border-t border-slate-200" style="margin-top: 1rem; /* Heavily reduced */; padding-top: 1.5rem !important;">
                                        <div class="graph-title text-sm" style="font-size: 0.875rem; line-height: 1.25rem;">
                                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <path d="M22 12h-4l-3 9L9 3l-3 9H2"></path>
                                            </svg>
                                            Visual Relationship Chart
                                        </div>
                                        <div class="graph-container bg-white">
                                            <div class="mermaid">
                                                <asp:Literal ID="litMermaidFamily" runat="server"></asp:Literal>
                                            </div>
                                        </div>
                                    </div>

                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                </div>
            </div>
        </div>
    </asp:Content>
