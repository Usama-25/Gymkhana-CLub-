<%@ Page Title="Department Wise Share" Language="C#" MasterPageFile="~/Sports_Management/SiteSports.master" AutoEventWireup="true" CodeFile="DepartmentWiseShare.aspx.cs" Inherits="DepartmentWiseShare" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .share-section {
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
            border: 2px solid var(--primary);
            border-radius: 12px;
            padding: 25px;
            margin-top: 20px;
        }
        .share-section-title {
            font-size: 16px;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .share-section-title i {
            font-size: 20px;
            color: var(--secondary);
        }
        .package-info-bar {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: white;
            padding: 15px 20px;
            border-radius: 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            box-shadow: 0 4px 15px rgba(30,58,95,0.3);
        }
        .package-info-bar .fee-display {
            font-size: 22px;
            font-weight: 800;
            color: var(--secondary);
        }
        .package-info-bar .pkg-name {
            font-size: 14px;
            font-weight: 600;
            opacity: 0.9;
        }
        .mode-toggle {
            display: flex;
            gap: 0;
            margin-bottom: 20px;
            border-radius: 8px;
            overflow: hidden;
            border: 2px solid var(--primary);
            width: fit-content;
        }
        .mode-toggle label {
            padding: 10px 25px;
            cursor: pointer;
            font-weight: 600;
            font-size: 13px;
            transition: all 0.3s;
            background: white;
            color: var(--primary);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .mode-toggle input[type="radio"] {
            display: none;
        }
        .mode-toggle input[type="radio"]:checked + label {
            background: var(--primary);
            color: white;
        }
        .dept-share-row {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 12px 15px;
            background: white;
            border: 1px solid var(--gray-200);
            border-radius: 8px;
            margin-bottom: 8px;
            transition: all 0.2s ease;
        }
        .dept-share-row:hover {
            border-color: var(--primary);
            box-shadow: 0 2px 8px rgba(30,58,95,0.1);
        }
        .dept-share-row .dept-check {
            flex: 0 0 auto;
        }
        .dept-share-row .dept-name {
            flex: 1;
            font-weight: 600;
            color: var(--gray-700);
            font-size: 13px;
        }
        .dept-share-row .dept-input {
            flex: 0 0 150px;
        }
        .dept-share-row .dept-input input {
            width: 100%;
            padding: 8px 12px;
            border: 2px solid var(--gray-300);
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            text-align: right;
            transition: border-color 0.2s;
        }
        .dept-share-row .dept-input input:focus {
            border-color: var(--primary);
            outline: none;
            box-shadow: 0 0 0 3px rgba(30,58,95,0.1);
        }
        .dept-share-row .dept-amount {
            flex: 0 0 130px;
            text-align: right;
            font-weight: 700;
            color: var(--success);
            font-size: 13px;
        }
        .total-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 20px;
            border-radius: 10px;
            margin-top: 15px;
            font-weight: 700;
            font-size: 15px;
        }
        .total-bar.valid {
            background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
            color: #065f46;
            border: 2px solid #10b981;
        }
        .total-bar.invalid {
            background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%);
            color: #991b1b;
            border: 2px solid #ef4444;
        }
        .total-bar.neutral {
            background: linear-gradient(135deg, #e0f2fe 0%, #bae6fd 100%);
            color: #0c4a6e;
            border: 2px solid #3b82f6;
        }
        .summary-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        .summary-card {
            background: white;
            border-radius: 10px;
            padding: 18px;
            text-align: center;
            border: 1px solid var(--gray-200);
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }
        .summary-card .sc-value {
            font-size: 24px;
            font-weight: 800;
            color: var(--primary);
        }
        .summary-card .sc-label {
            font-size: 11px;
            color: var(--gray-500);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-top: 4px;
        }
        .configured-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
        }
        .configured-badge.yes {
            background: #d1fae5;
            color: #065f46;
        }
        .configured-badge.no {
            background: #fee2e2;
            color: #991b1b;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="page-header-card">
        <h2><i class="fas fa-share-alt" style="margin-right:10px;"></i> Department Wise Share</h2>
        <span class="badge">Allocate Package Revenue to Departments</span>
    </div>

    <!-- Alert Message -->
    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert" style="display:block; margin-bottom: 20px; padding: 15px; border-radius: 8px; font-weight: bold;"></asp:Label>

    <div style="display:flex; gap:20px; flex-wrap:wrap;">

        <!-- Left Card: Departments from BasicDataInfo -->
        <div class="card" style="flex:1; min-width:280px;">
            <div class="card-header"><i class="fas fa-building" style="margin-right:8px;"></i> Available Departments</div>
            <div class="card-body" style="padding:0; overflow-x:auto;">
                <asp:GridView ID="gvDepartments" runat="server" AutoGenerateColumns="False" CssClass="grid-view" GridLines="None" EmptyDataText="No departments found.">
                    <Columns>
                        <asp:BoundField DataField="DepartmentID" HeaderText="ID" ItemStyle-Width="60px" />
                        <asp:BoundField DataField="DepartmentName" HeaderText="Department Name" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <!-- Right Card: Share Allocation -->
        <div class="card" style="flex:2; min-width:500px;">
            <div class="card-header"><i class="fas fa-project-diagram" style="margin-right:8px;"></i> Allocate Share to Departments</div>
            <div class="card-body">

                <!-- Step 1: Select Package -->
                <div class="form-group">
                    <label style="font-weight:700;"><i class="fas fa-box" style="margin-right:6px; color:var(--secondary);"></i> Select Subscription Package</label>
                    <asp:DropDownList ID="ddlPackages" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlPackages_SelectedIndexChanged" AppendDataBoundItems="true">
                        <asp:ListItem Text="-- Select Package --" Value="0"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <!-- Package Info Bar (shown after selection) -->
                <asp:Panel ID="pnlPackageInfo" runat="server" Visible="false">
                    <div class="package-info-bar">
                        <div>
                            <div class="pkg-name"><asp:Label ID="lblPackageName" runat="server"></asp:Label></div>
                            <div style="font-size:12px; opacity:0.7; margin-top:4px;">
                                <asp:Label ID="lblPackageType" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div>
                            <div style="font-size:11px; opacity:0.7;">Total Fee</div>
                            <div class="fee-display">PKR <asp:Label ID="lblPackageFee" runat="server"></asp:Label></div>
                        </div>
                    </div>

                    <!-- Step 2: Mode Toggle -->
                    <div style="margin-bottom:20px;">
                        <label style="font-weight:700; margin-bottom:8px; display:block;"><i class="fas fa-sliders-h" style="margin-right:6px; color:var(--secondary);"></i> Allocation Mode</label>
                        <asp:RadioButtonList ID="rdoShareMode" runat="server" RepeatDirection="Horizontal" AutoPostBack="true" OnSelectedIndexChanged="rdoShareMode_SelectedIndexChanged" style="display:flex; gap:0; border-radius:8px; overflow:hidden; border:2px solid var(--primary); width:fit-content;">
                            <asp:ListItem Text=" Percentage (%)" Value="Percentage" Selected="True"></asp:ListItem>
                            <asp:ListItem Text=" Fixed Amount (PKR)" Value="Amount"></asp:ListItem>
                        </asp:RadioButtonList>
                    </div>

                    <!-- Step 3: Department Checkboxes with Value Inputs -->
                    <div class="share-section">
                        <div class="share-section-title">
                            <i class="fas fa-building"></i> Select Departments & Assign Shares
                        </div>
                        
                        <asp:Repeater ID="rptDepartments" runat="server" OnItemDataBound="rptDepartments_ItemDataBound">
                            <ItemTemplate>
                                <div class="dept-share-row">
                                    <div class="dept-check">
                                        <asp:CheckBox ID="chkDept" runat="server" />
                                        <asp:HiddenField ID="hfDeptID" runat="server" Value='<%# Eval("DepartmentID") %>' />
                                    </div>
                                    <div class="dept-name">
                                        <%# Eval("DepartmentName") %>
                                    </div>
                                    <div class="dept-input">
                                        <asp:TextBox ID="txtShareValue" runat="server" CssClass="form-control" placeholder="0.00" TextMode="Number" step="0.01" onkeyup="calculateTotals()" onchange="calculateTotals()"></asp:TextBox>
                                    </div>
                                    <div class="dept-amount">
                                        <span class="calc-amount">PKR 0.00</span>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>

                        <!-- Total Bar -->
                        <div class="total-bar neutral" id="totalBar">
                            <span id="totalLabel">Total Allocated: 0%</span>
                            <span id="totalRemaining">Remaining: 100%</span>
                        </div>
                    </div>

                    <!-- Save Button -->
                    <div style="margin-top:20px; display:flex; gap:10px;">
                        <asp:Button ID="btnSaveShare" runat="server" Text="Save Share Allocation" CssClass="btn btn-primary" style="padding:12px 30px; font-size:15px;" OnClick="btnSaveShare_Click" />
                        <asp:Button ID="btnClearShare" runat="server" Text="Clear" CssClass="btn" style="background:var(--gray-300); color:var(--gray-800); padding:12px 20px;" OnClick="btnClearShare_Click" />
                    </div>
                </asp:Panel>

            </div>
        </div>

    </div>

    <!-- Configured Shares Grid -->
    <div class="card" style="margin-top:25px;">
        <div class="card-header" style="display:flex; justify-content:space-between; align-items:center;">
            <span><i class="fas fa-table" style="margin-right:8px;"></i> Configured Department Shares</span>
            <asp:Button ID="btnViewReport" runat="server" Text="View Full Report" CssClass="btn btn-primary" style="padding:6px 15px; font-size:12px; background:var(--info);" OnClick="btnViewReport_Click" />
        </div>
        <div class="card-body" style="padding:0; overflow-x:auto;">
            <asp:GridView ID="gvShares" runat="server" AutoGenerateColumns="False" CssClass="grid-view" GridLines="None" EmptyDataText="No department shares configured yet.">
                <Columns>
                    <asp:BoundField DataField="SportName" HeaderText="Sport" />
                    <asp:BoundField DataField="PackageName" HeaderText="Package" />
                    <asp:BoundField DataField="PackageFee" HeaderText="Total Fee" DataFormatString="PKR {0:N2}" />
                    <asp:BoundField DataField="DepartmentName" HeaderText="Department" />
                    <asp:TemplateField HeaderText="Share">
                        <ItemTemplate>
                            <strong style="color:var(--primary);">
                                <%# Eval("ShareMode").ToString() == "Percentage" 
                                    ? Eval("ShareValue", "{0:N2}") + "%" 
                                    : "PKR " + Eval("ShareValue", "{0:N2}") %>
                            </strong>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Amount (PKR)">
                        <ItemTemplate>
                            <strong style="color:var(--success);">PKR <%# Eval("ShareAmount", "{0:N2}") %></strong>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="CreatedOn" HeaderText="Created" DataFormatString="{0:dd-MMM-yyyy}" />
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <asp:HiddenField ID="hfPackageFee" runat="server" Value="0" />
    <asp:HiddenField ID="hfShareMode" runat="server" Value="Percentage" />

    <script type="text/javascript">
        function calculateTotals() {
            var rows = document.querySelectorAll('.dept-share-row');
            var packageFee = parseFloat(document.getElementById('<%= hfPackageFee.ClientID %>').value) || 0;
            var shareMode = document.getElementById('<%= hfShareMode.ClientID %>').value;
            var totalAllocated = 0;

            rows.forEach(function (row) {
                var checkbox = row.querySelector('input[type="checkbox"]');
                var input = row.querySelector('input[type="number"]');
                var amountSpan = row.querySelector('.calc-amount');

                if (!input || !amountSpan) return;

                var val = parseFloat(input.value) || 0;

                if (checkbox && checkbox.checked && val > 0) {
                    totalAllocated += val;
                    if (shareMode === 'Percentage') {
                        var amt = (packageFee * val / 100);
                        amountSpan.textContent = 'PKR ' + amt.toFixed(2);
                    } else {
                        amountSpan.textContent = 'PKR ' + val.toFixed(2);
                    }
                } else {
                    amountSpan.textContent = 'PKR 0.00';
                }
            });

            var totalBar = document.getElementById('totalBar');
            var totalLabel = document.getElementById('totalLabel');
            var totalRemaining = document.getElementById('totalRemaining');

            if (!totalBar || !totalLabel || !totalRemaining) return;

            if (shareMode === 'Percentage') {
                var remaining = 100 - totalAllocated;
                totalLabel.textContent = 'Total Allocated: ' + totalAllocated.toFixed(2) + '%';
                totalRemaining.textContent = 'Remaining: ' + remaining.toFixed(2) + '%';

                if (Math.abs(totalAllocated - 100) < 0.01) {
                    totalBar.className = 'total-bar valid';
                } else if (totalAllocated > 100) {
                    totalBar.className = 'total-bar invalid';
                } else {
                    totalBar.className = 'total-bar neutral';
                }
            } else {
                var remaining = packageFee - totalAllocated;
                totalLabel.textContent = 'Total Allocated: PKR ' + totalAllocated.toFixed(2);
                totalRemaining.textContent = 'Remaining: PKR ' + remaining.toFixed(2);

                if (Math.abs(totalAllocated - packageFee) < 0.01) {
                    totalBar.className = 'total-bar valid';
                } else if (totalAllocated > packageFee) {
                    totalBar.className = 'total-bar invalid';
                } else {
                    totalBar.className = 'total-bar neutral';
                }
            }
        }

        // Recalculate on checkbox change
        document.addEventListener('change', function (e) {
            if (e.target.type === 'checkbox') {
                calculateTotals();
            }
        });

        // Initial calculation on page load
        document.addEventListener('DOMContentLoaded', function () {
            calculateTotals();
        });
    </script>

</asp:Content>
