<%@ Page Language="C#" MasterPageFile="~/Complaint/Complaint.Master" AutoEventWireup="true" CodeFile="EmpComplaintViewAuthority.aspx.cs" Inherits="GymkhanaLibrary.Pages_EmpComplaintViewAuthority" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        .ca-table { width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; font-family: 'Outfit', sans-serif; color: #1e293b; margin: 0; border: none; }
        .ca-header th { background-color: #0f1e36 !important; color: #ffffff !important; font-weight: 700 !important; text-transform: uppercase !important; font-size: 11.5px !important; letter-spacing: 0.5px !important; padding: 14px 16px !important; border-bottom: 2px solid #c5a059 !important; text-align: left !important; }
        .ca-row td { background-color: #ffffff; border-bottom: 1px solid #e2e8f0; padding: 12px 16px; font-size: 13.5px; color: #1e293b; text-align: left; vertical-align: middle; }
        .ca-altrow td { background-color: #f8fafc; border-bottom: 1px solid #e2e8f0; padding: 12px 16px; font-size: 13.5px; color: #1e293b; text-align: left; vertical-align: middle; }

        .ac-dropdown {
            position: absolute;
            top: calc(100% + 4px);
            left: 0;
            right: 0;
            background: #ffffff;
            border: 1px solid #cbd5e1;
            border-radius: 10px;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.12), 0 8px 10px -6px rgba(0, 0, 0, 0.04);
            z-index: 9999;
            max-height: 240px;
            overflow-y: auto;
            display: none;
            padding: 6px;
        }
        .ac-item {
            padding: 10px 14px;
            border-radius: 6px;
            font-size: 13.5px;
            font-family: 'Outfit', sans-serif;
            color: #1e293b;
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: all 0.15s ease;
        }
        .ac-item:hover, .ac-item.selected {
            background-color: #f1f5f9;
            color: #0f1e36;
        }
        .ac-item-name { font-weight: 600; }
        .ac-item-id {
            font-size: 11px;
            font-weight: 700;
            color: #0f1e36;
            background: #f1f5f9;
            border: 1px solid #cbd5e1;
            padding: 2px 8px;
            border-radius: 12px;
        }
        .ac-no-results {
            padding: 12px 14px;
            font-size: 13px;
            color: #94a3b8;
            text-align: center;
            font-style: italic;
        }
    </style>
    <script type="text/javascript">
        var acSelectedIndex = -1;

        function initFilterEmployeeAutocomplete() {
            var input = document.getElementById('<%= txtFilterEmp.ClientID %>');
            var hf = document.getElementById('<%= hfFilterEmpID.ClientID %>');
            var dd = document.getElementById('acFilterSuggestions');
            if (!input || !dd) return;

            input.addEventListener('focus', function() { showFilterSuggestions(input, hf, dd); });
            input.addEventListener('input', function() { 
                if (hf) hf.value = '';
                showFilterSuggestions(input, hf, dd); 
            });

            input.addEventListener('keydown', function(e) {
                var items = dd.getElementsByClassName('ac-item');
                if (e.key === 'ArrowDown') {
                    e.preventDefault();
                    acSelectedIndex = Math.min(acSelectedIndex + 1, items.length - 1);
                    highlightItem(items);
                } else if (e.key === 'ArrowUp') {
                    e.preventDefault();
                    acSelectedIndex = Math.max(acSelectedIndex - 1, 0);
                    highlightItem(items);
                } else if (e.key === 'Enter') {
                    if (acSelectedIndex >= 0 && acSelectedIndex < items.length) {
                        e.preventDefault();
                        items[acSelectedIndex].click();
                    }
                } else if (e.key === 'Escape') {
                    dd.style.display = 'none';
                }
            });

            document.addEventListener('click', function(e) {
                if (!input.contains(e.target) && !dd.contains(e.target)) {
                    dd.style.display = 'none';
                }
            });
        }

        function showFilterSuggestions(input, hf, dd) {
            var query = input.value.toLowerCase().trim();
            var data = window.filterEmployeesData || [];
            var matches = data.filter(function(item) {
                return (item.display && item.display.toLowerCase().indexOf(query) > -1) || (item.id && item.id.indexOf(query) > -1);
            });

            dd.innerHTML = '';
            acSelectedIndex = -1;

            if (matches.length === 0) {
                dd.innerHTML = '<div class="ac-no-results">No matching employees found</div>';
                dd.style.display = 'block';
                return;
            }

            var maxItems = 60;
            matches.slice(0, maxItems).forEach(function(item) {
                var div = document.createElement('div');
                div.className = 'ac-item';
                div.innerHTML = '<span class="ac-item-name">' + escapeHtml(item.name) + '</span><span class="ac-item-id">ID: ' + escapeHtml(item.id) + '</span>';
                div.addEventListener('click', function() {
                    input.value = item.display;
                    if (hf) hf.value = item.id;
                    dd.style.display = 'none';
                });
                dd.appendChild(div);
            });

            dd.style.display = 'block';
        }

        function highlightItem(items) {
            for (var i = 0; i < items.length; i++) {
                if (i === acSelectedIndex) {
                    items[i].classList.add('selected');
                    items[i].scrollIntoView({ block: 'nearest' });
                } else {
                    items[i].classList.remove('selected');
                }
            }
        }

        function escapeHtml(str) {
            return (str || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
        }

        document.addEventListener('DOMContentLoaded', function() {
            initFilterEmployeeAutocomplete();
        });
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphBody" runat="server">
    <!-- Page Header Section -->
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; width: 100%;">
        <div>
            <h2 style="font-family: 'Playfair Display', serif; font-size: 28px; font-weight: 700; color: #0f1e36; margin: 0; line-height: 1.2;">Filter & View Authority Mappings</h2>
            <p style="color: #64748b; font-size: 14px; margin-top: 6px; margin-bottom: 0; font-family: 'Outfit', sans-serif;">Search and view existing employee permissions for target subdepartments.</p>
        </div>
        <a href="EmpComplaintAuthority.aspx" style="display: inline-flex; align-items: center; justify-content: center; padding: 10px 20px; border-radius: 8px; border: none; cursor: pointer; font-size: 13.5px; font-family: 'Outfit', sans-serif; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; text-decoration: none; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); height: 42px;">
            + Assign Authority
        </a>
    </div>

    <!-- Alert Message Panel -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false" style="width: 100%; margin-bottom: 20px;">
        <div style='padding: 16px 24px; border-radius: 8px; font-size: 14px; font-family: "Outfit", sans-serif; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; border-left: 4px solid; width: 100%; box-sizing: border-box; <%= AlertCssClass == "alert-success" ? "background-color: #d1fae5; color: #065f46; border-left-color: #10b981;" : "background-color: #fee2e2; color: #991b1b; border-left-color: #ef4444;" %>'>
            <span style="font-weight: 500;"><%= AlertMessage %></span>
        </div>
    </asp:Panel>

    <asp:Literal ID="litFilterEmployeesJson" runat="server" />

    <!-- Search & Filter Card -->
    <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); width: 100%; box-sizing: border-box;">
        <h3 style="font-family: 'Playfair Display', serif; font-size: 16px; font-weight: 700; color: #0f1e36; margin-top: 0; margin-bottom: 16px;">Filter Authority Mappings</h3>
        
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; align-items: end;">
            <div>
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block; font-family: 'Outfit', sans-serif;">SubDepartment</label>
                <asp:DropDownList ID="ddlFilterSubDept" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterSubDept_SelectedIndexChanged" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; font-family: 'Outfit', sans-serif; outline: none; background-color: #ffffff; color: #1e293b; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
            </div>

            <div style="position: relative;">
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block; font-family: 'Outfit', sans-serif;">Employee</label>
                <div style="position: relative; width: 100%;">
                    <asp:TextBox ID="txtFilterEmp" runat="server" autocomplete="off" placeholder="Type employee name or ID to filter..." style="width: 100%; padding: 10px 36px 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; font-family: 'Outfit', sans-serif; outline: none; background-color: #ffffff; color: #1e293b; box-sizing: border-box; height: 42px; transition: all 0.2s ease;" onfocus="this.style.borderColor='#c5a059'; this.style.boxShadow='0 0 0 3px rgba(197, 160, 89, 0.15)';" onblur="this.style.borderColor='#cbd5e1'; this.style.boxShadow='none';" />
                    <i class="fas fa-search" style="position: absolute; right: 14px; top: 14px; color: #94a3b8; font-size: 14px; pointer-events: none;"></i>
                    <div id="acFilterSuggestions" class="ac-dropdown"></div>
                </div>
                <asp:HiddenField ID="hfFilterEmpID" runat="server" />
            </div>

            <div>
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block; font-family: 'Outfit', sans-serif;">Status</label>
                <asp:DropDownList ID="ddlFilterStatus" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; font-family: 'Outfit', sans-serif; outline: none; background-color: #ffffff; color: #1e293b; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';">
                    <asp:ListItem Text="- All Statuses -" Value="" />
                    <asp:ListItem Text="Active" Value="1" />
                    <asp:ListItem Text="Inactive" Value="0" />
                </asp:DropDownList>
            </div>

            <div style="display: flex; gap: 8px; height: 42px;">
                <asp:Button ID="btnFilter" runat="server" Text="Filter" style="flex: 1; padding: 10px 20px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-family: 'Outfit', sans-serif; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); height: 42px;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnFilter_Click" />
                <asp:Button ID="btnFilterReset" runat="server" Text="Reset" style="padding: 10px 20px; border-radius: 8px; border: 1px solid #cbd5e1; cursor: pointer; font-size: 13px; font-family: 'Outfit', sans-serif; font-weight: 600; background-color: #ffffff; color: #64748b; transition: all 0.2s ease; height: 42px;" onmouseover="this.style.backgroundColor='#f1f5f9'; this.style.color='#1e293b';" onmouseout="this.style.backgroundColor='#ffffff'; this.style.color='#64748b';" OnClick="btnFilterReset_Click" />
            </div>
        </div>
    </div>

    <!-- Authorities Grid Card -->
    <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); width: 100%; box-sizing: border-box;">
        <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
            <asp:GridView ID="gvAuthorities" runat="server" AutoGenerateColumns="false" GridLines="None"
                OnRowCommand="gvAuthorities_RowCommand" CssClass="ca-table">
                <HeaderStyle CssClass="ca-header" />
                <RowStyle CssClass="ca-row" />
                <AlternatingRowStyle CssClass="ca-altrow" />
                <Columns>
                    <asp:TemplateField HeaderText="Sr#">
                        <HeaderStyle Width="60px" />
                        <ItemTemplate>
                            <%# Container.DataItemIndex + 1 %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="SubDepartment">
                        <ItemTemplate>
                            <div style="font-weight: 700; color: #0f1e36; font-size: 14px;"><%# Eval("SubDepartmentName") %></div>
                            <div style="font-size: 12px; color: #64748b; margin-top: 2px;">Dept: <%# Eval("TargetDeptName") %></div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Authorized Employee">
                        <ItemTemplate>
                            <div style="font-weight: 700; color: #0f1e36; font-size: 14px;"><%# Eval("EmployeeName") %></div>
                            <div style="font-size: 12px; color: #64748b; margin-top: 2px;">Emp ID: <%# Eval("EmpID") %> <%# Eval("EmployeeDeptName") != DBNull.Value ? " | Dept: " + Eval("EmployeeDeptName") : "" %></div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Status">
                        <HeaderStyle Width="110px" />
                        <ItemTemplate>
                            <span style='display: inline-block; padding: 5px 12px; border-radius: 9999px; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.3px; <%# Convert.ToBoolean(Eval("IsActive")) ? "background-color: #d1fae5; color: #065f46; border: 1px solid #a7f3d0;" : "background-color: #fee2e2; color: #991b1b; border: 1px solid #fca5a5;" %>'>
                                <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Assigned Date">
                        <HeaderStyle Width="160px" />
                        <ItemTemplate>
                            <%# Convert.ToDateTime(Eval("CreatedDate")).ToString("dd-MMM-yyyy hh:mm tt") %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Actions">
                        <HeaderStyle Width="120px" />
                        <ItemTemplate>
                            <asp:LinkButton ID="lnkToggle" runat="server" CommandName="ToggleStatus" CommandArgument='<%# Eval("AuthorityID") %>' OnClientClick='<%# Convert.ToBoolean(Eval("IsActive")) ? "return confirm(\"Are you sure you want to deactivate this viewing authority?\");" : "return confirm(\"Are you sure you want to activate this viewing authority?\");" %>' style="text-decoration: none; font-size: 13px; font-weight: 700; color: #c5a059; display: inline-block; transition: color 0.2s ease;" onmouseover="this.style.color='#aa8441';" onmouseout="this.style.color='#c5a059';">
                                <%# Convert.ToBoolean(Eval("IsActive")) ? "Deactivate" : "Activate" %>
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div style="padding: 36px; text-align: center; color: #64748b; font-family: 'Outfit', sans-serif; font-size: 14px;">No employee subdepartment authority mappings found.</div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
