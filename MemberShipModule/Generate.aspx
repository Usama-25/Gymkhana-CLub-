<%@ Page Title="Application Tracking" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true"
    CodeFile="Generate.aspx.cs" Inherits="InterviewList.Interviewlist1" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
        <style>
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

            /* Loading Overlay */
            .loading-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(15, 23, 42, 0.45); backdrop-filter: blur(4px); z-index: 9999; display: flex; align-items: center; justify-content: center; }
            .loading-box { background: #ffffff; border-radius: 16px; padding: 2rem 2.5rem; box-shadow: 0 20px 60px rgba(0,0,0,0.15); display: flex; flex-direction: column; align-items: center; gap: 1rem; }
            .loading-spinner { width: 44px; height: 44px; border: 4px solid #e0d5c5; border-top: 4px solid #C9A84C; border-radius: 50%; animation: spin 0.8s linear infinite; }
            .loading-text { font-size: 0.95rem; font-weight: 600; color: #1A1A2E; letter-spacing: 0.02em; }
            .loading-subtext { font-size: 0.8rem; color: #a09080; margin-top: -0.5rem; }
            @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        </style>
                <script type="text/javascript">
                    (function () {
                        'use strict';
                        window.onpageshow = function (event) {
                            if (event.persisted) window.location.reload();
                        };
                        if (window.history.replaceState) {
                            window.history.replaceState(null, null, window.location.href);
                        }
                        document.addEventListener('DOMContentLoaded', function () {
                            var forms = document.getElementsByTagName('form');
                            for (var i = 0; i < forms.length; i++) {
                                forms[i].setAttribute('autocomplete', 'off');
                            }
                        });
                    })();
        </script>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">

        <asp:UpdatePanel ID="upMain" runat="server">
            <ContentTemplate>

                <div style="margin-top: 0.75rem !important; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif !important;">
                    <div style="background-color: #ffffff !important; border-radius: 14px !important; padding: 2rem 2.25rem !important; border: 1px solid #e0d5c5 !important; box-shadow: 0 4px 24px rgba(0,0,0,0.06) !important; position: relative !important; overflow: hidden !important;">

                        <!-- Page Header -->
                        <div style="display: flex !important; align-items: center !important; justify-content: space-between !important; margin-bottom: 2rem !important; padding-bottom: 1.25rem !important; border-bottom: 2px solid #e0d5c5 !important;">
                            <div>
                                <h1 style="font-size: 1.6rem !important; font-weight: 800 !important; color: #1A1A2E !important; margin: 0 0 0.25rem 0 !important; letter-spacing: -0.02em !important;">Application Tracking &amp; Interview</h1>
                                <p style="color: #7a7a7a !important; font-size: 0.9rem !important; margin: 0 !important; font-weight: 400 !important;">Generate interview lists and manage applicant status</p>
                            </div>
                        </div>

                        <!-- ═══ Section 1: Interview Configuration (Hidden) ═══ -->
                        <asp:PlaceHolder ID="phInterviewConfig" runat="server" Visible="false">
                        <div style="padding: 0 !important; margin-bottom: 1.75rem !important;">
                            <div style="display: flex !important; align-items: center !important; gap: 0.75rem !important; margin-bottom: 1.25rem !important; padding-bottom: 0.75rem !important; border-bottom: 1px solid #e0d5c5 !important;">
                                <div style="width: 36px !important; height: 36px !important; background: linear-gradient(135deg, #faf7f2, #f5ecd5) !important; color: #C9A84C !important; display: flex !important; align-items: center !important; justify-content: center !important; border-radius: 8px !important;">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                                </div>
                                <div>
                                    <h2 style="font-size: 1.1rem !important; font-weight: 700 !important; margin: 0 !important; color: #1A1A2E !important;">Interview Configuration</h2>
                                    <p style="font-size: 0.8rem !important; color: #7a7a7a !important; margin: 0 !important;">Set up new interview sessions</p>
                                </div>
                            </div>

                            <div style="display: grid !important; grid-template-columns: repeat(4, 1fr) !important; gap: 1.25rem !important; align-items: end !important; margin-bottom: 1.25rem !important;">
                                <div style="display: flex !important; flex-direction: column !important; gap: 0.35rem !important;">
                                    <label style="display: block !important; font-size: 0.8rem !important; font-weight: 600 !important; color: #374151 !important; text-transform: uppercase !important; letter-spacing: 0.04em !important;">Interview By</label>
                                    <asp:TextBox ID="txtInterviewBy" runat="server" placeholder="Interviewer Name" style="display: block !important; width: 100% !important; padding: 0.5rem 0.75rem !important; font-size: 0.875rem !important; font-weight: 400 !important; line-height: 1.4 !important; color: #1A1A2E !important; background-color: #ffffff !important; border: 1px solid #e0d5c5 !important; border-radius: 8px !important; outline: none !important; box-sizing: border-box !important;" />
                                </div>
                                <div style="display: flex !important; flex-direction: column !important; gap: 0.35rem !important;">
                                    <label style="display: block !important; font-size: 0.8rem !important; font-weight: 600 !important; color: #374151 !important; text-transform: uppercase !important; letter-spacing: 0.04em !important;">Interview Date</label>
                                    <asp:TextBox ID="txtInterviewDate" runat="server" TextMode="Date" style="display: block !important; width: 100% !important; padding: 0.5rem 0.75rem !important; font-size: 0.875rem !important; font-weight: 400 !important; line-height: 1.4 !important; color: #1A1A2E !important; background-color: #ffffff !important; border: 1px solid #e0d5c5 !important; border-radius: 8px !important; outline: none !important; box-sizing: border-box !important;" />
                                </div>
                                <div style="display: flex !important; flex-direction: column !important; gap: 0.35rem !important;">
                                    <label style="display: block !important; font-size: 0.8rem !important; font-weight: 600 !important; color: #374151 !important; text-transform: uppercase !important; letter-spacing: 0.04em !important;">Remarks</label>
                                    <asp:TextBox ID="TextBox1" runat="server" placeholder="Optional remarks" style="display: block !important; width: 100% !important; padding: 0.5rem 0.75rem !important; font-size: 0.875rem !important; font-weight: 400 !important; line-height: 1.4 !important; color: #1A1A2E !important; background-color: #ffffff !important; border: 1px solid #e0d5c5 !important; border-radius: 8px !important; outline: none !important; box-sizing: border-box !important;" />
                                </div>
                                <div style="display: flex !important; align-items: flex-end !important;">
                                    <asp:Button ID="Button1" runat="server" Text="Create Session" OnClick="btnSave1_Click" style="width: 100% !important; padding: 0.55rem 1.25rem !important; border-radius: 8px !important; font-weight: 600 !important; font-size: 0.875rem !important; cursor: pointer !important; text-align: center !important; display: inline-block !important; line-height: 1.4 !important; border: none !important; background: linear-gradient(135deg, #C9A84C, #8B5E3C) !important; color: #ffffff !important; box-shadow: 0 2px 8px rgba(201,168,76,0.25) !important;" />
                                </div>
                            </div>

                            <!-- Interviewers Grid -->
                            <div id="divFilter" runat="server" style="background: #ffffff !important; border: 1px solid #e0d5c5 !important; border-radius: 10px !important; overflow: hidden !important; margin-bottom: 1.5rem !important; box-shadow: 0 1px 3px rgba(0,0,0,0.04) !important;">
                                <asp:GridView ID="gvInterviewers" runat="server" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvInterviewers_RowCommand" style="width: 100% !important; border-collapse: collapse !important; font-size: 0.875rem !important; text-align: left !important;">
                                    <HeaderStyle BackColor="#faf7f2" Font-Bold="true" ForeColor="#1A1A2E" />
                                    <RowStyle BackColor="#ffffff" ForeColor="#1A1A2E" />
                                    <AlternatingRowStyle BackColor="#faf7f2" />
                                    <Columns>
                                        <asp:TemplateField HeaderText="ID">
                                            <HeaderStyle CssClass="" />
                                            <ItemTemplate>
                                                <span style="display: inline-block !important; padding: 0.2rem 0.6rem !important; background: #F7F3EE !important; color: #8B5E3C !important; border-radius: 6px !important; font-size: 0.8rem !important; font-weight: 600 !important; font-family: monospace !important;">INT-<%# Eval("Iid") %></span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField DataField="Iby" HeaderText="Interviewer" />
                                        <asp:BoundField DataField="Idate" HeaderText="Date" DataFormatString="{0:yyyy-MM-dd}" />
                                        <asp:BoundField DataField="Remarks" HeaderText="Remarks" />
                                        <asp:TemplateField HeaderText="Actions">
                                            <ItemTemplate>
                                                <div style="display: flex !important; gap: 0.5rem !important;">
                                                    <asp:Button ID="btnView" runat="server" Text="Select" CommandName="View" Visible="false" CommandArgument='<%# Eval("Iid") %>' style="padding: 0.3rem 0.75rem !important; border-radius: 6px !important; font-weight: 600 !important; font-size: 0.8rem !important; cursor: pointer !important; border: 1px solid #e0d5c5 !important; background-color: #ffffff !important; color: #1A1A2E !important;" />
                                                    <asp:Button ID="btnAdd" runat="server" Text="Add Applicant" CommandName="Add" CommandArgument='<%# Eval("Iid") %>' style="padding: 0.3rem 0.75rem !important; border-radius: 6px !important; font-weight: 600 !important; font-size: 0.8rem !important; cursor: pointer !important; border: none !important; background: linear-gradient(135deg, #C9A84C, #8B5E3C) !important; color: #ffffff !important;" />
                                                </div>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                    <EmptyDataTemplate>
                                        <div style="padding: 2.5rem 1rem !important; text-align: center !important; color: #a09080 !important; background: #faf7f2 !important; border: 1px dashed #e0d5c5 !important; border-radius: 10px !important; margin: 0.5rem !important;">
                                            <p style="margin: 0 !important; font-size: 0.9rem !important; font-weight: 500 !important;">No interview sessions found</p>
                                        </div>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                            </div>

                            <!-- Selected Interview Details -->
                            <div id="divNewInterview" runat="server" visible="false" style="display: flex !important; flex-wrap: wrap !important; align-items: center !important; justify-content: space-between !important; gap: 1.25rem !important; padding: 1rem 1.5rem !important; margin-bottom: 1.5rem !important; background: linear-gradient(135deg, #faf7f2, #f0f9ff) !important; border: 1px solid #bfdbfe !important; border-radius: 10px !important;">
                                <div style="display: flex !important; gap: 2.5rem !important; align-items: center !important;">
                                    <div>
                                        <span style="display: block !important; font-size: 0.7rem !important; font-weight: 700 !important; color: #C9A84C !important; text-transform: uppercase !important; letter-spacing: 0.06em !important; margin-bottom: 0.15rem !important;">Interview ID</span>
                                        <div style="font-weight: 700 !important; color: #1A1A2E !important; font-size: 0.95rem !important;"><asp:Label ID="lblIid" runat="server" style="font-weight: 700 !important; color: #1A1A2E !important;" /></div>
                                    </div>
                                    <div>
                                        <span style="display: block !important; font-size: 0.7rem !important; font-weight: 700 !important; color: #C9A84C !important; text-transform: uppercase !important; letter-spacing: 0.06em !important; margin-bottom: 0.15rem !important;">Name</span>
                                        <div style="font-weight: 700 !important; color: #1A1A2E !important; font-size: 0.95rem !important;"><asp:Label ID="lblName" runat="server" style="font-weight: 700 !important; color: #1A1A2E !important;" /></div>
                                    </div>
                                    <div>
                                        <span style="display: block !important; font-size: 0.7rem !important; font-weight: 700 !important; color: #C9A84C !important; text-transform: uppercase !important; letter-spacing: 0.06em !important; margin-bottom: 0.15rem !important;">Date</span>
                                        <div style="font-weight: 700 !important; color: #1A1A2E !important; font-size: 0.95rem !important;"><asp:Label ID="lblDate" runat="server" style="font-weight: 700 !important; color: #1A1A2E !important;" /></div>
                                    </div>
                                </div>
                                <div>
                                    <asp:Button ID="btnRemove" runat="server" Text="Clear Selection" OnClick="btnRemove_Click" style="padding: 0.4rem 1rem !important; border-radius: 6px !important; font-weight: 600 !important; font-size: 0.8rem !important; cursor: pointer !important; border: 1px solid #fca5a5 !important; background-color: #fef2f2 !important; color: #dc2626 !important;" />
                                </div>
                                <asp:HiddenField ID="hfInterviewId" runat="server" />
                            </div>
                        </div>
                        </asp:PlaceHolder>

                        <!-- ═══ Section 2: Applicant Search ═══ -->
                        <div style="padding: 0 !important; margin-bottom: 1.75rem !important;">
                            <div style="display: flex !important; align-items: center !important; gap: 0.75rem !important; margin-bottom: 1.25rem !important; padding-bottom: 0.75rem !important; border-bottom: 1px solid #e0d5c5 !important;">
                                <div style="width: 36px !important; height: 36px !important; background: linear-gradient(135deg, #f0fdf4, #dcfce7) !important; color: #16a34a !important; display: flex !important; align-items: center !important; justify-content: center !important; border-radius: 8px !important;">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                                </div>
                                <div>
                                    <h2 style="font-size: 1.1rem !important; font-weight: 700 !important; margin: 0 !important; color: #1A1A2E !important;">Applicant Search</h2>
                                    <p style="font-size: 0.8rem !important; color: #7a7a7a !important; margin: 0 !important;">Find applicants to schedule</p>
                                </div>
                            </div>

                            <div style="background-color: #faf7f2 !important; border: 1px solid #e0d5c5 !important; border-radius: 12px !important; padding: 1.5rem !important; margin-bottom: 1.5rem !important;">
                                <div style="display: grid !important; grid-template-columns: repeat(4, 1fr) !important; gap: 1.25rem !important; align-items: end !important;">
                                    <div style="grid-column: span 2 !important; display: flex !important; flex-direction: column !important; gap: 0.35rem !important;">
                                        <label style="display: block !important; font-size: 0.8rem !important; font-weight: 600 !important; color: #374151 !important; text-transform: uppercase !important; letter-spacing: 0.04em !important;">Membership Type</label>
                                        <asp:DropDownList ID="ddlMembership" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlMembership_SelectedIndexChanged" style="display: block !important; width: 100% !important; padding: 0.5rem 0.75rem !important; font-size: 0.875rem !important; font-weight: 400 !important; line-height: 1.4 !important; color: #1A1A2E !important; background-color: #ffffff !important; border: 1px solid #e0d5c5 !important; border-radius: 8px !important; outline: none !important; box-sizing: border-box !important;" />
                                    </div>
                                    <div style="display: flex !important; flex-direction: column !important; gap: 0.35rem !important;">
                                        <label style="display: block !important; font-size: 0.8rem !important; font-weight: 600 !important; color: #374151 !important; text-transform: uppercase !important; letter-spacing: 0.04em !important;">Start Date</label>
                                        <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" style="display: block !important; width: 100% !important; padding: 0.5rem 0.75rem !important; font-size: 0.875rem !important; font-weight: 400 !important; line-height: 1.4 !important; color: #1A1A2E !important; background-color: #ffffff !important; border: 1px solid #e0d5c5 !important; border-radius: 8px !important; outline: none !important; box-sizing: border-box !important;" />
                                    </div>
                                    <div style="display: flex !important; flex-direction: column !important; gap: 0.35rem !important;">
                                        <label style="display: block !important; font-size: 0.8rem !important; font-weight: 600 !important; color: #374151 !important; text-transform: uppercase !important; letter-spacing: 0.04em !important;">End Date</label>
                                        <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" style="display: block !important; width: 100% !important; padding: 0.5rem 0.75rem !important; font-size: 0.875rem !important; font-weight: 400 !important; line-height: 1.4 !important; color: #1A1A2E !important; background-color: #ffffff !important; border: 1px solid #e0d5c5 !important; border-radius: 8px !important; outline: none !important; box-sizing: border-box !important;" />
                                    </div>
                                </div>
                                <div style="display: grid !important; grid-template-columns: repeat(4, 1fr) !important; gap: 1.25rem !important; align-items: end !important; margin-top: 1.25rem !important;">
                                    <div style="grid-column: span 4 !important; display: flex !important; flex-direction: column !important; gap: 0.35rem !important;">
                                        <label style="display: block !important; font-size: 0.8rem !important; font-weight: 600 !important; color: #374151 !important; text-transform: uppercase !important; letter-spacing: 0.04em !important;">Search Keyword (Applicant Name, Father Name, CNIC - separate multiple terms with '+')</label>
                                        <asp:TextBox ID="txtSearchKeyword" runat="server" placeholder="e.g. Ali + Ahmad + 35201" style="display: block !important; width: 100% !important; padding: 0.5rem 0.75rem !important; font-size: 0.875rem !important; font-weight: 400 !important; line-height: 1.4 !important; color: #1A1A2E !important; background-color: #ffffff !important; border: 1px solid #e0d5c5 !important; border-radius: 8px !important; outline: none !important; box-sizing: border-box !important;" />
                                    </div>
                                </div>
                                <div style="display: flex !important; justify-content: flex-end !important; gap: 0.75rem !important; margin-top: 1.25rem !important;">
                                    <asp:Button ID="btnFilter" runat="server" Text="Search Applicants" OnClick="btnFilter_Click" style="padding: 0.55rem 1.25rem !important; border-radius: 8px !important; font-weight: 600 !important; font-size: 0.875rem !important; cursor: pointer !important; text-align: center !important; border: 1px solid #e0d5c5 !important; background-color: #ffffff !important; color: #1A1A2E !important; box-shadow: 0 1px 2px rgba(0,0,0,0.05) !important;" />
                                    <asp:Button ID="btnSave" runat="server" Text="Add Selected to Interview" OnClick="btnSave_Click" style="padding: 0.55rem 1.25rem !important; border-radius: 8px !important; font-weight: 600 !important; font-size: 0.875rem !important; cursor: pointer !important; text-align: center !important; border: none !important; background: linear-gradient(135deg, #C9A84C, #8B5E3C) !important; color: #ffffff !important; box-shadow: 0 2px 8px rgba(201,168,76,0.25) !important;" />
                                </div>
                            </div>

                            <asp:HiddenField ID="hfInterviewMainId" runat="server" />
                            <asp:HiddenField ID="hfSelectedNIC" runat="server" />

                            <div style="background: #ffffff !important; border: 1px solid #e0d5c5 !important; border-radius: 10px !important; overflow: hidden !important; margin-bottom: 1.5rem !important; max-height: 400px !important; overflow-y: auto !important; box-shadow: 0 1px 3px rgba(0,0,0,0.04) !important;">
                                <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataKeyNames="NIC,City,Memberships,Email,MFee,Status,DeferDate,DeferYear,MainMemberNo,CreatedOn,MaritalStatus,DOB,FatherName,ApplicantName,MainMemberStatus,Mobile,Nationality" GridLines="None" OnRowDataBound="GridView1_RowDataBound" style="width: 100% !important; border-collapse: collapse !important; font-size: 0.875rem !important; text-align: left !important;">
                                    <HeaderStyle BackColor="#faf7f2" Font-Bold="true" ForeColor="#1A1A2E" Height="40px" />
                                    <RowStyle BackColor="#ffffff" ForeColor="#1A1A2E" Height="45px" />
                                    <AlternatingRowStyle BackColor="#faf7f2" />
                                    <Columns>
                                        <asp:TemplateField HeaderText="Select">
                                            <HeaderStyle Width="60px" HorizontalAlign="Center" />
                                            <ItemStyle HorizontalAlign="Center" />
                                            <ItemTemplate>
                                                <asp:CheckBox ID="chkSelect" runat="server" style="transform: scale(1.1) !important;" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField DataField="ApplicantName" HeaderText="Applicant Name" />
                                        <asp:BoundField DataField="FatherName" HeaderText="Father Name" />
                                        <asp:TemplateField HeaderText="NIC">
                                            <ItemTemplate>
                                                <span style="font-family: monospace !important; font-size: 0.8rem !important; color: #8B5E3C !important;"><%# Eval("NIC") %></span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField DataField="MainMemberNo" HeaderText="Main Member No" NullDisplayText="-" />
                                        <asp:BoundField DataField="MainMemberName" HeaderText="Main Member Name" NullDisplayText="-" />
                                        <asp:TemplateField HeaderText="Main Member Status">
                                            <ItemTemplate>
                                                <span style='<%# GetMainMemberStatusStyle(Eval("MainMemberStatus")) %>'>
                                                    <%# Eval("MainMemberStatus") != null && !string.IsNullOrEmpty(Eval("MainMemberStatus").ToString()) ? Eval("MainMemberStatus").ToString() : "N/A" %>
                                                </span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField DataField="CreatedOn" HeaderText="Apply Date" DataFormatString="{0:yyyy-MM-dd}" />
                                        <asp:BoundField DataField="MaritalStatus" HeaderText="Marital Status" />
                                        <asp:BoundField DataField="Mobile" HeaderText="Mobile" />
                                        <asp:BoundField DataField="City" HeaderText="City" />
                                        <asp:BoundField DataField="Memberships" HeaderText="Membership" />
                                        <asp:BoundField DataField="Email" HeaderText="Email" />
                                        <asp:BoundField DataField="MFee" HeaderText="Fee" DataFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" ItemStyle-Font-Bold="true" />
                                        <asp:TemplateField HeaderText="Status">
                                            <ItemTemplate>
                                                <span style='<%# GetStatusStyle(Eval("Status")) %>'>
                                                    <%# GetStatusText(Eval("Status")) %>
                                                </span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                    <EmptyDataTemplate>
                                        <div style="padding: 2.5rem 1rem !important; text-align: center !important; color: #a09080 !important; background: #faf7f2 !important; border: 1px dashed #e0d5c5 !important; border-radius: 10px !important; margin: 0.5rem !important;">
                                            <p style="margin: 0 !important; font-size: 0.9rem !important; font-weight: 500 !important;">No applicants found matching criteria</p>
                                        </div>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                            </div>
                        </div>


                        <!-- ═══ Section 3: Final Interview List ═══ -->
                        <div style="padding: 0 !important; margin-bottom: 1.75rem !important;">
                            <div style="display: flex !important; align-items: center !important; gap: 0.75rem !important; margin-bottom: 1.25rem !important; padding-bottom: 0.75rem !important; border-bottom: 1px solid #e0d5c5 !important;">
                                <div style="width: 36px !important; height: 36px !important; background: linear-gradient(135deg, #fef2f2, #fee2e2) !important; color: #ef4444 !important; display: flex !important; align-items: center !important; justify-content: center !important; border-radius: 8px !important;">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line></svg>
                                </div>
                                <div>
                                    <h2 style="font-size: 1.1rem !important; font-weight: 700 !important; margin: 0 !important; color: #1A1A2E !important;">Final Interview List</h2>
                                    <p style="font-size: 0.8rem !important; color: #7a7a7a !important; margin: 0 !important;">Review and finalize applicant list</p>
                                </div>
                            </div>

                            <div style="background: #ffffff !important; border: 1px solid #e0d5c5 !important; border-radius: 10px !important; overflow: hidden !important; margin-bottom: 1.5rem !important; box-shadow: 0 1px 3px rgba(0,0,0,0.04) !important;">
                                <asp:GridView ID="GridView2" runat="server" AutoGenerateColumns="False" OnRowCommand="GridView2_RowCommand" GridLines="None" style="width: 100% !important; border-collapse: collapse !important; font-size: 0.875rem !important; text-align: left !important;">
                                    <HeaderStyle BackColor="#faf7f2" Font-Bold="true" ForeColor="#1A1A2E" Height="40px" />
                                    <RowStyle BackColor="#ffffff" ForeColor="#1A1A2E" Height="45px" />
                                    <AlternatingRowStyle BackColor="#faf7f2" />
                                    <Columns>
                                        <asp:TemplateField HeaderText="Select">
                                            <HeaderStyle Width="60px" HorizontalAlign="Center" />
                                            <ItemStyle HorizontalAlign="Center" />
                                            <ItemTemplate>
                                                <asp:CheckBox ID="chkSelect1" runat="server" style="transform: scale(1.1) !important;" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField DataField="ApplicantName" HeaderText="Applicant Name" />
                                        <asp:BoundField DataField="FatherName" HeaderText="Father Name" />
                                        <asp:TemplateField HeaderText="NIC">
                                            <ItemTemplate>
                                                <span style="font-family: monospace !important; font-size: 0.8rem !important; color: #8B5E3C !important;"><%# Eval("NIC") %></span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField DataField="MainMemberNo" HeaderText="Main Member No" NullDisplayText="-" />
                                        <asp:BoundField DataField="CreatedOn" HeaderText="Apply Date" DataFormatString="{0:yyyy-MM-dd}" />
                                        <asp:BoundField DataField="MaritalStatus" HeaderText="Marital Status" />
                                        <asp:BoundField DataField="Mobile" HeaderText="Mobile" />
                                        <asp:BoundField DataField="Email" HeaderText="Email" />
                                        <asp:BoundField DataField="MFee" HeaderText="Fee" DataFormatString="{0:N0}" />
                                        <asp:TemplateField HeaderText="Action">
                                            <ItemStyle HorizontalAlign="Center" />
                                            <ItemTemplate>
                                                <asp:Button ID="btnDelete" runat="server" CommandName="DeleteRow" CommandArgument='<%# Container.DataItemIndex %>' Text="Remove" style="padding: 0.25rem 0.75rem !important; border-radius: 6px !important; font-weight: 600 !important; font-size: 0.75rem !important; cursor: pointer !important; border: 1px solid #fca5a5 !important; background-color: #fef2f2 !important; color: #dc2626 !important; transition: all 0.2s !important;" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                    <EmptyDataTemplate>
                                        <div style="padding: 2.5rem 1rem !important; text-align: center !important; color: #a09080 !important; background: #faf7f2 !important; border: 1px dashed #e0d5c5 !important; border-radius: 10px !important; margin: 0.5rem !important;">
                                            <p style="margin: 0 !important; font-size: 0.9rem !important; font-weight: 500 !important;">No applicants added to final list yet</p>
                                        </div>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                            </div>

                            <!-- Finalize Buttons -->
                            <div style="text-align: center !important; margin-bottom: 1.5rem !important;">
                                <asp:Label ID="lblActionIndicator" runat="server" style="color: #ef4444 !important; font-weight: 500 !important; font-style: italic !important; font-size: 0.875rem !important;" />
                            </div>

                            <div style="display: flex !important; justify-content: center !important; gap: 1rem !important; padding-top: 1.5rem !important; border-top: 1px solid #e0d5c5 !important;">
                                <asp:Button ID="btnupdate" runat="server" Text="Save Changes" OnClick="btnUpdate_Click" style="min-width: 160px !important; padding: 0.75rem 1.5rem !important; border-radius: 10px !important; font-weight: 600 !important; font-size: 0.9rem !important; cursor: pointer !important; text-align: center !important; border: none !important; background: linear-gradient(135deg, #C9A84C, #8B5E3C) !important; color: #ffffff !important; box-shadow: 0 4px 12px rgba(201,168,76,0.2) !important;" />

                                <asp:Button ID="btnReject" runat="server" Text="Reject Selected" OnClick="btnReject_Click" Visible="false" style="min-width: 160px !important; padding: 0.75rem 1.5rem !important; border-radius: 10px !important; font-weight: 600 !important; font-size: 0.9rem !important; cursor: pointer !important; text-align: center !important; border: 1px solid #ef4444 !important; background-color: #ffffff !important; color: #ef4444 !important;" />

                                <asp:Button ID="btnPostponed" runat="server" Text="Postpone" OnClick="btnPostponed_Click" Visible="false" style="min-width: 160px !important; padding: 0.75rem 1.5rem !important; border-radius: 10px !important; font-weight: 600 !important; font-size: 0.9rem !important; cursor: pointer !important; text-align: center !important; border: 1px solid #f59e0b !important; background-color: #ffffff !important; color: #f59e0b !important;" />

                                <asp:Button ID="btnFinalize" runat="server" Text="Finalize Interview" OnClick="btnFinalize_Click" Visible="false" style="min-width: 160px !important; padding: 0.75rem 1.5rem !important; border-radius: 10px !important; font-weight: 600 !important; font-size: 0.9rem !important; cursor: pointer !important; text-align: center !important; border: none !important; background: linear-gradient(135deg, #10b981, #059669) !important; color: #ffffff !important; box-shadow: 0 4px 12px rgba(16,185,129,0.2) !important;" />
                            </div>

                            <asp:HiddenField ID="hfRemarks" runat="server" />
                            <asp:HiddenField ID="hfActionType" runat="server" />
                            <asp:Button ID="btnProcessAction" runat="server" OnClick="btnProcessAction_Click" style="display: none !important;" />
                        </div>
                    </div>
                </div>

                <!-- Panel (Modern Modal) -->
                <asp:Panel ID="pnlRemarks" runat="server" Visible="false">
                    <div style="position: fixed !important; top: 0 !important; left: 0 !important; right: 0 !important; bottom: 0 !important; background-color: rgba(0,0,0,0.6) !important; z-index: 1000 !important; display: flex !important; align-items: center !important; justify-content: center !important; padding: 1rem !important; backdrop-filter: blur(4px) !important;">
                        <div style="background-color: #ffffff !important; border-radius: 16px !important; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04) !important; width: 100% !important; max-width: 500px !important; transform: scale(1) !important; transition: all 0.3s ease !important; overflow: hidden !important;">
                            
                            <!-- Modal Header -->
                            <div style="display: flex !important; justify-content: space-between !important; align-items: center !important; padding: 1.25rem 1.5rem !important; border-bottom: 1px solid #F7F3EE !important; background-color: #ffffff !important;">
                                <h3 style="font-size: 1.25rem !important; font-weight: 700 !important; color: #1e293b !important; margin: 0 !important;">
                                    <asp:Label ID="lblPanelTitle" runat="server" Text="Action Required" />
                                </h3>
                                <asp:Button ID="btnClosePanel" runat="server" Text="&times;" OnClick="btnClosePanel_Click" style="background: transparent !important; border: none !important; color: #a09080 !important; font-size: 1.75rem !important; cursor: pointer !important; line-height: 1 !important; padding: 0 !important; transition: color 0.2s !important;" />
                            </div>

                            <!-- Modal Body -->
                            <div style="padding: 1.5rem !important;">
                                <p style="color: #7a7a7a !important; font-size: 0.95rem !important; margin: 0 0 1.25rem 0 !important; line-height: 1.5 !important;">Are you sure you want to proceed with this action?</p>

                                <div style="display: flex !important; flex-direction: column !important; gap: 0.5rem !important;">
                                    <label style="display: block !important; font-size: 0.85rem !important; font-weight: 600 !important; color: #8B5E3C !important;">Remarks (Optional)</label>
                                    <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="4" placeholder="Enter reason or comments..." style="display: block !important; width: 100% !important; padding: 0.75rem !important; font-size: 0.9rem !important; font-weight: 400 !important; line-height: 1.5 !important; color: #1A1A2E !important; background-color: #ffffff !important; border: 1px solid #e0d5c5 !important; border-radius: 10px !important; outline: none !important; box-sizing: border-box !important; resize: vertical !important;" />
                                </div>
                            </div>

                            <!-- Modal Footer -->
                            <div style="padding: 1.25rem 1.5rem !important; background-color: #faf7f2 !important; border-top: 1px solid #F7F3EE !important; display: flex !important; justify-content: flex-end !important; gap: 0.75rem !important;">
                                <asp:Button ID="btnCancelAction" runat="server" Text="Cancel" OnClick="btnCancelAction_Click" style="padding: 0.6rem 1.25rem !important; border-radius: 8px !important; font-weight: 600 !important; font-size: 0.875rem !important; cursor: pointer !important; border: 1px solid #e0d5c5 !important; background-color: #ffffff !important; color: #8B5E3C !important;" />
                                <asp:Button ID="btnConfirmAction" runat="server" Text="Confirm" OnClick="btnConfirmAction_Click" style="padding: 0.6rem 1.25rem !important; border-radius: 8px !important; font-weight: 600 !important; font-size: 0.875rem !important; cursor: pointer !important; border: none !important; background: linear-gradient(135deg, #C9A84C, #8B5E3C) !important; color: #ffffff !important; box-shadow: 0 4px 12px rgba(201,168,76,0.2) !important;" />
                            </div>
                        </div>
                    </div>
                </asp:Panel>
            </ContentTemplate>
        </asp:UpdatePanel>

        <asp:UpdateProgress ID="upProgress" runat="server" AssociatedUpdatePanelID="upMain" DisplayAfter="200">
            <ProgressTemplate>
                <div class="loading-overlay">
                    <div class="loading-box">
                        <div class="loading-spinner"></div>
                        <div class="loading-text">Processing...</div>
                        <div class="loading-subtext">Please wait while we fetch the data</div>
                    </div>
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
    </asp:Content>
