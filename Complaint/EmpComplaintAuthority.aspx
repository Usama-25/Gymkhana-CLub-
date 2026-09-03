<%@ Page Language="C#" MasterPageFile="~/Complaint/Complaint.Master" AutoEventWireup="true" CodeFile="EmpComplaintAuthority.aspx.cs" Inherits="GymkhanaLibrary.Pages_EmpComplaintAuthority" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        .ca-table { width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; font-family: 'Outfit', sans-serif; color: #1e293b; margin: 0; border: none; }
        .ca-header th { background-color: #0f1e36 !important; color: #ffffff !important; font-weight: 700 !important; text-transform: uppercase !important; font-size: 11.5px !important; letter-spacing: 0.5px !important; padding: 14px 16px !important; border-bottom: 2px solid #c5a059 !important; text-align: left !important; font-family: 'Outfit', sans-serif !important; }
        .ca-row td { background-color: #ffffff !important; border-bottom: 1px solid #e2e8f0 !important; padding: 12px 16px !important; font-size: 13.5px !important; color: #1e293b !important; text-align: left !important; vertical-align: middle !important; font-family: 'Outfit', sans-serif !important; }
        .ca-altrow td { background-color: #f8fafc !important; border-bottom: 1px solid #e2e8f0 !important; padding: 12px 16px !important; font-size: 13.5px !important; color: #1e293b !important; text-align: left !important; vertical-align: middle !important; font-family: 'Outfit', sans-serif !important; }
        
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
        .ac-item-name { font-weight: 600; font-family: 'Outfit', sans-serif; }
        .ac-item-id {
            font-size: 11px;
            font-weight: 700;
            color: #0f1e36;
            background: #f1f5f9;
            border: 1px solid #cbd5e1;
            padding: 2px 8px;
            border-radius: 12px;
            font-family: 'Outfit', sans-serif;
        }
        .ac-no-results {
            padding: 12px 14px;
            font-size: 13px;
            color: #94a3b8;
            text-align: center;
            font-style: italic;
            font-family: 'Outfit', sans-serif;
        }
    </style>
    <script type="text/javascript">
        var acSelectedIndex = -1;

        function initEmployeeAutocomplete() {
            var input = document.getElementById('<%= txtEmployee.ClientID %>');
            var hf = document.getElementById('<%= hfEmpID.ClientID %>');
            var dd = document.getElementById('acSuggestions');
            if (!input || !dd) return;

            input.addEventListener('focus', function() { showSuggestions(input, hf, dd); });
            input.addEventListener('input', function() { 
                if (hf) hf.value = '';
                showSuggestions(input, hf, dd); 
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

        function showSuggestions(input, hf, dd) {
            var query = input.value.toLowerCase().trim();
            var data = window.allEmployeesData || [];
            var matches = data.filter(function(item) {
                return (item.display && item.display.toLowerCase().indexOf(query) > -1) || (item.id && item.id.indexOf(query) > -1);
            });

            dd.innerHTML = '';
            acSelectedIndex = -1;

            if (matches.length === 0) {
                dd.innerHTML = '<div style="padding: 12px 14px; font-size: 13px; color: #94a3b8; text-align: center; font-style: italic; font-family: \'Outfit\', sans-serif;">No matching employees found</div>';
                dd.style.display = 'block';
                return;
            }

            var maxItems = 60;
            matches.slice(0, maxItems).forEach(function(item) {
                var div = document.createElement('div');
                div.className = 'ac-item';
                div.setAttribute('style', 'padding: 10px 14px; border-radius: 6px; font-size: 13.5px; font-family: \'Outfit\', sans-serif; color: #1e293b; cursor: pointer; display: flex; justify-content: space-between; align-items: center; transition: all 0.15s ease; background-color: #ffffff;');
                div.innerHTML = '<span style="font-weight: 600; font-family: \'Outfit\', sans-serif; color: inherit;">' + escapeHtml(item.name) + '</span><span style="font-size: 11px; font-weight: 700; color: #0f1e36; background: #f1f5f9; border: 1px solid #cbd5e1; padding: 2px 8px; border-radius: 12px; font-family: \'Outfit\', sans-serif;">ID: ' + escapeHtml(item.id) + '</span>';
                
                div.onmouseover = function() {
                    this.style.backgroundColor = '#f1f5f9';
                    this.style.color = '#0f1e36';
                };
                div.onmouseout = function() {
                    if (!this.classList.contains('selected')) {
                        this.style.backgroundColor = '#ffffff';
                        this.style.color = '#1e293b';
                    }
                };
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
                    items[i].style.backgroundColor = '#f1f5f9';
                    items[i].style.color = '#0f1e36';
                    items[i].scrollIntoView({ block: 'nearest' });
                } else {
                    items[i].classList.remove('selected');
                    items[i].style.backgroundColor = '#ffffff';
                    items[i].style.color = '#1e293b';
                }
            }
        }

        function escapeHtml(str) {
            return (str || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
        }

        function grantEntireDepartment() {
            var deptDd = document.getElementById('<%= ddlDeptSelect.ClientID %>');
            if (!deptDd) return;
            var deptId = deptDd.value;
            if (!deptId || deptId === "0") {
                showToast("Please select a department from the dropdown first.", "warning");
                return;
            }
            var deptName = deptDd.options[deptDd.selectedIndex].text;
            var rows = document.querySelectorAll('tr[data-dept-id="' + deptId + '"]');
            if (rows.length === 0) {
                showToast("No subdepartments found for " + deptName, "warning");
                return;
            }
            var count = 0;
            rows.forEach(function(tr) {
                var chk = tr.querySelector('input[type="checkbox"]');
                if (chk) {
                    chk.checked = true;
                    count++;
                }
            });
            showToast("Granted access to all " + count + " subdepartments in " + deptName + ".", "success");
        }

        function revokeEntireDepartment() {
            var deptDd = document.getElementById('<%= ddlDeptSelect.ClientID %>');
            if (!deptDd) return;
            var deptId = deptDd.value;
            if (!deptId || deptId === "0") {
                showToast("Please select a department from the dropdown first.", "warning");
                return;
            }
            var deptName = deptDd.options[deptDd.selectedIndex].text;
            var rows = document.querySelectorAll('tr[data-dept-id="' + deptId + '"]');
            if (rows.length === 0) {
                showToast("No subdepartments found for " + deptName, "warning");
                return;
            }
            if (!confirm("Are you sure you want to revoke access for all subdepartments in " + deptName + "?")) {
                return;
            }
            var count = 0;
            rows.forEach(function(tr) {
                var chk = tr.querySelector('input[type="checkbox"]');
                if (chk) {
                    chk.checked = false;
                    count++;
                }
            });
            showToast("Revoked access from all " + count + " subdepartments in " + deptName + ".", "error");
        }

        function quickSelectDept(deptId, deptName) {
            var deptDd = document.getElementById('<%= ddlDeptSelect.ClientID %>');
            if (deptDd) {
                deptDd.value = deptId;
            }
            grantEntireDepartment();
        }

        function grantAllSubDepts() {
            var rows = document.querySelectorAll('tr[data-dept-id]');
            var count = 0;
            rows.forEach(function(tr) {
                var chk = tr.querySelector('input[type="checkbox"]');
                if (chk) {
                    chk.checked = true;
                    count++;
                }
            });
            showToast("Granted access to ALL " + count + " subdepartments across all departments.", "success");
        }

        function revokeAllSubDepts() {
            if (!confirm("Are you sure you want to revoke access for ALL subdepartments across all departments?")) {
                return;
            }
            var rows = document.querySelectorAll('tr[data-dept-id]');
            rows.forEach(function(tr) {
                var chk = tr.querySelector('input[type="checkbox"]');
                if (chk) chk.checked = false;
            });
            showToast("Revoked access from ALL subdepartments.", "error");
        }

        function toggleAllSubDepts(masterChk) {
            var isChecked = masterChk.checked;
            var rows = document.querySelectorAll('tr[data-dept-id]');
            rows.forEach(function(tr) {
                if (tr.style.display !== 'none') {
                    var chk = tr.querySelector('input[type="checkbox"]');
                    if (chk) chk.checked = isChecked;
                }
            });
        }

        function filterSubDeptGrid() {
            var deptFilter = document.getElementById('<%= ddlDeptFilter.ClientID %>');
            var textInput = document.getElementById('txtSubDeptFilter');
            var selectedDeptId = deptFilter ? deptFilter.value : "0";
            var textQuery = textInput ? textInput.value.toLowerCase().trim() : "";

            var rows = document.querySelectorAll('tr[data-dept-id]');
            rows.forEach(function(tr) {
                var deptId = tr.getAttribute('data-dept-id') || '0';
                var deptName = tr.getAttribute('data-dept-name') || '';
                var tdName = tr.cells[1];
                var subDeptName = tdName ? (tdName.textContent || tdName.innerText || '').toLowerCase() : '';

                var matchesDept = (selectedDeptId === "0" || deptId === selectedDeptId);
                var matchesText = (textQuery === "" || subDeptName.indexOf(textQuery) > -1 || deptName.toLowerCase().indexOf(textQuery) > -1);

                if (matchesDept && matchesText) {
                    tr.style.display = '';
                } else {
                    tr.style.display = 'none';
                }
            });
        }

        function showToast(message, type) {
            var toast = document.getElementById('toastNotification');
            if (!toast) return;
            toast.innerText = message;
            toast.style.borderColor = type === 'success' ? '#10b981' : (type === 'warning' ? '#f59e0b' : '#ef4444');
            toast.style.display = 'block';
            setTimeout(function() {
                toast.style.display = 'none';
            }, 3500);
        }

        document.addEventListener('DOMContentLoaded', function() {
            initEmployeeAutocomplete();
        });
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphBody" runat="server">
    <!-- Page Header Section -->
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; width: 100%; box-sizing: border-box;">
        <div style="box-sizing: border-box;">
            <h2 style="font-family: 'Playfair Display', serif; font-size: 28px; font-weight: 700; color: #0f1e36; margin: 0; line-height: 1.2;">Assign Department & SubDepartment Authority</h2>
            <p style="color: #64748b; font-size: 14px; margin-top: 6px; margin-bottom: 0; font-family: 'Outfit', sans-serif; line-height: 1.5;">Search an employee to view and grant access to entire departments or individual subdepartments simultaneously.</p>
        </div>
        <a href="EmpComplaintViewAuthority.aspx" style="display: inline-flex; align-items: center; justify-content: center; padding: 10px 20px; border-radius: 8px; border: 1px solid #cbd5e1; cursor: pointer; font-size: 13.5px; font-family: 'Outfit', sans-serif; font-weight: 600; background-color: #ffffff; color: #0f1e36; text-decoration: none; transition: all 0.2s ease; height: 42px; box-sizing: border-box; flex-shrink: 0;" onmouseover="this.style.backgroundColor='#f1f5f9';" onmouseout="this.style.backgroundColor='#ffffff';">
            View All Authority Mappings
        </a>
    </div>

    <!-- Alert Message Panel -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false" style="width: 100%; margin-bottom: 20px; box-sizing: border-box;">
        <div style='padding: 16px 24px; border-radius: 8px; font-size: 14px; font-family: "Outfit", sans-serif; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; border-left: 4px solid; width: 100%; box-sizing: border-box; <%= AlertCssClass == "alert-success" ? "background-color: #d1fae5; color: #065f46; border-left-color: #10b981;" : "background-color: #fee2e2; color: #991b1b; border-left-color: #ef4444;" %>'>
            <span style="font-weight: 500; font-family: 'Outfit', sans-serif; font-size: 14px; color: inherit;"><%= AlertMessage %></span>
        </div>
    </asp:Panel>

    <asp:Literal ID="litAllEmployeesJson" runat="server" />

    <!-- Employee Search Card -->
    <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); width: 100%; box-sizing: border-box;">
        <h3 style="font-family: 'Playfair Display', serif; font-size: 18px; font-weight: 700; color: #0f1e36; margin-top: 0; margin-bottom: 20px; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px;">Step 1: Select Employee</h3>

        <div style="display: flex; gap: 16px; align-items: flex-end; flex-wrap: wrap; width: 100%; box-sizing: border-box;">
            <div style="flex: 1; min-width: 280px; position: relative; box-sizing: border-box;">
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block; font-family: 'Outfit', sans-serif;">Search Employee <span style="color: #ef4444; font-weight: 700;">*</span></label>
                <div style="position: relative; width: 100%; box-sizing: border-box;">
                    <asp:TextBox ID="txtEmployee" runat="server" autocomplete="off" placeholder="Type employee name or ID..." style="width: 100%; padding: 10px 36px 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; font-family: 'Outfit', sans-serif; outline: none; background-color: #ffffff; color: #1e293b; box-sizing: border-box; height: 42px; transition: all 0.2s ease;" onfocus="this.style.borderColor='#c5a059'; this.style.boxShadow='0 0 0 3px rgba(197, 160, 89, 0.15)';" onblur="this.style.borderColor='#cbd5e1'; this.style.boxShadow='none';" />
                    <i class="fas fa-search" style="position: absolute; right: 14px; top: 14px; color: #94a3b8; font-size: 14px; pointer-events: none;"></i>
                    <div id="acSuggestions" class="ac-dropdown" style="position: absolute; top: calc(100% + 4px); left: 0; right: 0; background: #ffffff; border: 1px solid #cbd5e1; border-radius: 10px; box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.12), 0 8px 10px -6px rgba(0, 0, 0, 0.04); z-index: 9999; max-height: 240px; overflow-y: auto; display: none; padding: 6px; box-sizing: border-box;"></div>
                </div>
                <asp:HiddenField ID="hfEmpID" runat="server" />
            </div>

            <div style="box-sizing: border-box;">
                <asp:Button ID="btnLoadEmployee" runat="server" Text="Load Permissions" style="padding: 10px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13.5px; font-family: 'Outfit', sans-serif; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); height: 42px; box-sizing: border-box;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnLoadEmployee_Click" />
            </div>
        </div>
    </div>

    <!-- SubDepartments & Department Permission Grid Card -->
    <asp:Panel ID="pnlGridCard" runat="server" Visible="false" style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); width: 100%; box-sizing: border-box;">
        
        <!-- Entire Department Quick Selection Panel -->
        <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 18px 20px; margin-bottom: 20px; box-shadow: inset 0 1px 2px rgba(0,0,0,0.02); width: 100%; box-sizing: border-box;">
            <div style="font-size: 13.5px; font-weight: 700; color: #0f1e36; margin-bottom: 12px; font-family: 'Outfit', sans-serif; display: flex; align-items: center; gap: 8px;">
                <i class="fas fa-building" style="color: #c5a059; font-size: 15px;"></i> Entire Department Quick Selection
                <span style="font-size: 12px; font-weight: 400; color: #64748b; font-family: 'Outfit', sans-serif;">(Quickly grant or revoke access for all subdepartments under an entire department)</span>
            </div>
            
            <div style="display: flex; gap: 12px; align-items: center; flex-wrap: wrap; width: 100%; box-sizing: border-box;">
                <div style="min-width: 220px; flex: 1; max-width: 320px; box-sizing: border-box;">
                    <asp:DropDownList ID="ddlDeptSelect" runat="server" style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; font-family: 'Outfit', sans-serif; height: 38px; color: #0f1e36; background-color: #ffffff; outline: none; transition: border-color 0.2s ease; box-sizing: border-box;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                </div>
                <button type="button" onclick="grantEntireDepartment(); return false;" style="padding: 8px 18px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-family: 'Outfit', sans-serif; font-weight: 700; background: #10b981; color: #ffffff; transition: all 0.2s ease; height: 38px; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 2px 4px rgba(16, 185, 129, 0.2); box-sizing: border-box;" onmouseover="this.style.backgroundColor='#059669';" onmouseout="this.style.backgroundColor='#10b981';">
                    <i class="fas fa-check-circle" style="font-size: 13px;"></i> Grant Entire Department
                </button>
                <button type="button" onclick="revokeEntireDepartment(); return false;" style="padding: 8px 18px; border-radius: 8px; border: 1px solid #ef4444; cursor: pointer; font-size: 13px; font-family: 'Outfit', sans-serif; font-weight: 700; background: #ffffff; color: #ef4444; transition: all 0.2s ease; height: 38px; display: inline-flex; align-items: center; gap: 6px; box-sizing: border-box;" onmouseover="this.style.backgroundColor='#fee2e2';" onmouseout="this.style.backgroundColor='#ffffff';">
                    <i class="fas fa-times-circle" style="font-size: 13px;"></i> Revoke Entire Department
                </button>

                <div style="height: 24px; width: 1px; background-color: #cbd5e1; margin: 0 4px;"></div>

                <button type="button" onclick="grantAllSubDepts(); return false;" style="padding: 8px 14px; border-radius: 8px; border: 1px solid #cbd5e1; cursor: pointer; font-size: 12.5px; font-family: 'Outfit', sans-serif; font-weight: 600; background: #ffffff; color: #0f1e36; transition: all 0.2s ease; height: 38px; box-sizing: border-box;" onmouseover="this.style.backgroundColor='#f1f5f9';" onmouseout="this.style.backgroundColor='#ffffff';">
                    Grant All Depts
                </button>
                <button type="button" onclick="revokeAllSubDepts(); return false;" style="padding: 8px 14px; border-radius: 8px; border: 1px solid #cbd5e1; cursor: pointer; font-size: 12.5px; font-family: 'Outfit', sans-serif; font-weight: 600; background: #ffffff; color: #64748b; transition: all 0.2s ease; height: 38px; box-sizing: border-box;" onmouseover="this.style.backgroundColor='#f1f5f9';" onmouseout="this.style.backgroundColor='#ffffff';">
                    Revoke All
                </button>
            </div>
        </div>

        <div style="display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 16px; margin-bottom: 16px; border-bottom: 1px solid #e2e8f0; padding-bottom: 16px; width: 100%; box-sizing: border-box;">
            <div style="box-sizing: border-box;">
                <h3 style="font-family: 'Playfair Display', serif; font-size: 18px; font-weight: 700; color: #0f1e36; margin: 0;">Step 2: Department & SubDepartment Permissions</h3>
                <p style="font-size: 13px; color: #64748b; margin-top: 4px; margin-bottom: 0; font-family: 'Outfit', sans-serif;">Managing complaint viewing authorities for <span style="font-weight: 700; color: #0f1e36; font-family: 'Outfit', sans-serif;"><asp:Literal ID="litSelectedEmpName" runat="server" /></span></p>
            </div>
            <div style="display: flex; gap: 12px; align-items: flex-end; flex-wrap: wrap; box-sizing: border-box;">
                <div style="box-sizing: border-box;">
                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 4px; display: block; font-family: 'Outfit', sans-serif;">Filter by Department</label>
                    <asp:DropDownList ID="ddlDeptFilter" runat="server" onchange="filterSubDeptGrid()" style="padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; font-family: 'Outfit', sans-serif; outline: none; background-color: #ffffff; color: #1e293b; box-sizing: border-box; height: 38px; min-width: 170px;" />
                </div>
                <div style="width: 240px; max-width: 100%; box-sizing: border-box;">
                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 4px; display: block; font-family: 'Outfit', sans-serif;">Search SubDepartments</label>
                    <input type="text" id="txtSubDeptFilter" onkeyup="filterSubDeptGrid()" placeholder="Type subdepartment..." style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; font-family: 'Outfit', sans-serif; outline: none; background-color: #ffffff; color: #1e293b; box-sizing: border-box; height: 38px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                </div>
            </div>
        </div>

        <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; background-color: #ffffff; -webkit-overflow-scrolling: touch; box-sizing: border-box;">
            <asp:GridView ID="gvSubDeptAccess" runat="server" AutoGenerateColumns="false" GridLines="None" DataKeyNames="SubDept_Id" CssClass="ca-table" style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; font-family: 'Outfit', sans-serif; color: #1e293b; margin: 0; border: none;" OnRowDataBound="gvSubDeptAccess_RowDataBound">
                <HeaderStyle CssClass="ca-header" />
                <RowStyle CssClass="ca-row" />
                <AlternatingRowStyle CssClass="ca-altrow" />
                <Columns>
                    <asp:TemplateField HeaderText="Sr#">
                        <HeaderStyle Width="60px" />
                        <ItemTemplate>
                            <span style="font-family: 'Outfit', sans-serif; font-size: 13.5px; color: #1e293b;"><%# Container.DataItemIndex + 1 %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="SubDepartment Name">
                        <ItemTemplate>
                            <div style="font-weight: 700; color: #0f1e36; font-size: 14px; font-family: 'Outfit', sans-serif;"><%# Eval("SubDept_Name") %></div>
                            <asp:HiddenField ID="hfExistingAuthID" runat="server" Value='<%# Eval("AuthorityID") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Department">
                        <ItemTemplate>
                            <div style="display: flex; align-items: center; justify-content: space-between; gap: 8px; box-sizing: border-box;">
                                <span style="font-size: 13px; color: #475569; font-weight: 600; font-family: 'Outfit', sans-serif;"><%# Eval("Dept_Name") %></span>
                                <button type="button" onclick="quickSelectDept('<%# Eval("Dept_Id") %>', '<%# System.Web.HttpUtility.JavaScriptStringEncode(Eval("Dept_Name").ToString()) %>'); return false;" title="Grant entire <%# Eval("Dept_Name") %> department" style="background: #f1f5f9; border: 1px solid #cbd5e1; color: #0f1e36; font-size: 11px; font-weight: 600; padding: 3px 8px; border-radius: 6px; cursor: pointer; transition: all 0.15s ease; font-family: 'Outfit', sans-serif;" onmouseover="this.style.background='#e2e8f0';" onmouseout="this.style.background='#f1f5f9';">
                                    <i class="fas fa-building" style="color: #c5a059; font-size: 10px;"></i> Select Entire Dept
                                </button>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField>
                        <HeaderTemplate>
                            <div style="display: flex; align-items: center; gap: 6px; box-sizing: border-box;">
                                <input type="checkbox" id="chkMasterSelect" onclick="toggleAllSubDepts(this)" style="cursor: pointer; width: 15px; height: 15px; accent-color: #c5a059; margin: 0;" title="Select/Deselect All Visible SubDepartments" />
                                <span style="font-family: 'Outfit', sans-serif; font-size: 11.5px; font-weight: 700; color: #ffffff; text-transform: uppercase; letter-spacing: 0.5px;">Grant Access</span>
                            </div>
                        </HeaderTemplate>
                        <HeaderStyle Width="170px" />
                        <ItemTemplate>
                            <asp:CheckBox ID="chkHasAccess" runat="server" Checked='<%# Convert.ToBoolean(Eval("HasAccess")) %>' Text="&nbsp;Access Granted" onclick="if (!this.checked) { if (!confirm('Are you sure you want to revoke access for this subdepartment?')) { this.checked = true; } }" style="font-size: 13.5px; font-weight: 600; color: #0f1e36; font-family: 'Outfit', sans-serif; cursor: pointer; display: inline-flex; align-items: center;" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div style="padding: 36px; text-align: center; color: #64748b; font-family: 'Outfit', sans-serif; font-size: 14px;">No subdepartments found.</div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>

        <div style="margin-top: 20px; display: flex; justify-content: flex-end; box-sizing: border-box;">
            <asp:Button ID="btnSaveAuthorities" runat="server" Text="Save Permissions" style="padding: 12px 32px; border-radius: 8px; border: none; cursor: pointer; font-size: 13.5px; font-family: 'Outfit', sans-serif; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 4px 12px rgba(197, 160, 89, 0.25); height: 44px; box-sizing: border-box;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 6px 16px rgba(197, 160, 89, 0.35)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 4px 12px rgba(197, 160, 89, 0.25)';" OnClick="btnSaveAuthorities_Click" />
        </div>
    </asp:Panel>

    <!-- Floating Toast Notification -->
    <div id="toastNotification" style="position: fixed; bottom: 24px; right: 24px; background: #0f1e36; color: #ffffff; padding: 12px 20px; border-radius: 8px; font-size: 13.5px; font-family: 'Outfit', sans-serif; box-shadow: 0 10px 25px rgba(0,0,0,0.2); z-index: 99999; display: none; border-left: 4px solid #c5a059; font-weight: 500;"></div>
</asp:Content>


