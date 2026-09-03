<%@ Page Title="Assign Deals" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" AutoEventWireup="true" CodeFile="AssignDeals.aspx.cs" Inherits="AssignDeals" %>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .assign-deals-page {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }

        .assign-deals-page .page-header {
            background-color: var(--surface);
            padding: 1.5rem;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
        }

        .assign-deals-page .page-header h1 {
            font-size: 1.5rem;
            color: var(--primary-dark);
            font-weight: 700;
        }

        .assign-deals-page .form-card {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
        }

        .assign-deals-page .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 1.25rem;
            margin-bottom: 1.5rem;
        }

        .assign-deals-page .form-group {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .assign-deals-page .form-label {
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--text);
        }

        .assign-deals-page .form-control {
            width: 100%;
            padding: 0.6rem 0.8rem;
            font-size: 0.9rem;
            font-family: inherit;
            color: var(--text);
            background-color: #f8fafc;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            transition: all 0.2s ease;
        }

        .assign-deals-page .form-control:focus {
            outline: none;
            border-color: var(--primary-lt);
            background-color: var(--surface);
            box-shadow: 0 0 0 3px rgba(37, 99, 168, 0.15);
        }

        .assign-deals-page .checkbox-group {
            display: flex;
            align-items: center;
            gap: 1.5rem;
            margin-top: 0.5rem;
        }

        .assign-deals-page .checkbox-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.9rem;
            color: var(--text);
        }

        .assign-deals-page .btn-submit {
            display: inline-block;
            background-color: var(--primary);
            color: var(--surface);
            padding: 0.6rem 1.5rem;
            border: none;
            border-radius: var(--radius);
            font-weight: 600;
            font-size: 0.9rem;
            cursor: pointer;
            transition: background-color 0.2s ease;
        }

        .assign-deals-page .btn-submit:hover {
            background-color: var(--primary-lt);
        }

        .assign-deals-page .grid-card {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
            margin-top: 1.5rem;
        }

        .assign-deals-page .grid-wrapper table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.9rem;
        }

        .assign-deals-page .grid-wrapper th {
            background-color: #f8fafc;
            color: var(--text);
            font-weight: 600;
            padding: 0.75rem 1rem;
            border-bottom: 2px solid var(--border);
            text-align: left;
        }

        .assign-deals-page .grid-wrapper td {
            padding: 0.75rem 1rem;
            border-bottom: 1px solid var(--border);
            color: var(--text);
        }
    </style>
    <script type="text/javascript">
        window.onload = function () {
            var ddlDeal = document.getElementById("<%= ddlDeal.ClientID %>");
            var txtSetupName = document.getElementById("<%= txtSetupName.ClientID %>");
            var ddlType = document.getElementById("<%= ddlType.ClientID %>");
            var chkAllowOne = document.getElementById("<%= chkAllowOne.ClientID %>");
            var chkAllowMany = document.getElementById("<%= chkAllowMany.ClientID %>");
            var btnSave = document.getElementById("<%= btnSave.ClientID %>");

            chkAllowOne.checked = true;
            chkAllowMany.checked = false;

            loadDeals();

            if (ddlDeal) {
                ddlDeal.onchange = function () {
                    loadAssignedDeals(ddlDeal.value);
                };
            }

            if (ddlType) {
                ddlType.onchange = function () {
                    handleTypeChange();
                };
            }

            if (btnSave) {
                btnSave.onclick = function (e) {
                    e.preventDefault();
                    saveDeal();
                };
            }

            if (chkAllowOne && chkAllowMany) {
                chkAllowOne.onchange = function () {
                    if (chkAllowOne.checked) chkAllowMany.checked = false;
                };
                chkAllowMany.onchange = function () {
                    if (chkAllowMany.checked) chkAllowOne.checked = false;
                };
            }

            function loadDeals() {
                if (typeof $ === 'undefined') return;
                $.ajax({
                    type: "POST",
                    url: "<%= ResolveUrl("~/Baquetsystems/AssignDeals.aspx/GetMainDeals") %>",
                    data: "{}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var deals = response.d;
                        if (!deals || !ddlDeal) return;
                        for (var i = 0; i < deals.length; i++) {
                            var name = (deals[i].DealName || "").trim();
                            var id = (deals[i].DID || "").toString().trim();
                            if (name !== "") {
                                ddlDeal.add(new Option(name, id));
                            }
                        }
                    },
                    error: function (xhr, status, error) {
                        console.log("Error loading deals:", error);
                    }
                });
            }

            function saveDeal() {
                if (typeof $ === 'undefined') return;
                var payload = JSON.stringify({
                    superName: txtSetupName.value.trim(),
                    dealId: ddlDeal.value,
                    type: ddlType.value,
                    allowOne: chkAllowOne.checked,
                    allowMany: chkAllowMany.checked
                });

                $.ajax({
                    type: "POST",
                    url: "<%= ResolveUrl("~/Baquetsystems/AssignDeals.aspx/SaveSetup") %>",
                    data: payload,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        alert(response.d);
                    }
                });
            }

            function loadAssignedDeals(dealId) {
                if (typeof $ === 'undefined') return;
                $.ajax({
                    type: "POST",
                    url: "<%= ResolveUrl("~/Baquetsystems/AssignDeals.aspx/GetAssignedDeals") %>",
                    data: JSON.stringify({ dealId: dealId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var list = response.d;
                        var tbody = document.querySelector("#tblAssignedDeals tbody");
                        if (!tbody) return;
                        tbody.innerHTML = "";
                        for (var i = 0; i < list.length; i++) {
                            var row = list[i];
                            var tr = document.createElement("tr");
                            tr.innerHTML = "<td>" + (i + 1) + "</td>" +
                                "<td>" + row.DealName + "</td>" +
                                "<td>" + row.SuperName + "</td>" +
                                "<td>" + row.Category + "</td>";
                            tbody.appendChild(tr);
                        }
                    }
                });
            }

            function handleTypeChange() {}
        };
    </script>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="assign-deals-page">
        <div class="page-header">
            <h1>Assign & Create Banquet Deals</h1>
        </div>

        <div class="form-card">
            <div class="form-grid">
                <div class="form-group">
                    <asp:Label runat="server" AssociatedControlID="ddlDeal" CssClass="form-label">Event Name</asp:Label>
                    <asp:DropDownList ID="ddlDeal" runat="server" CssClass="form-control"></asp:DropDownList>
                </div>

                <div class="form-group">
                    <asp:Label runat="server" AssociatedControlID="txtSetupName" CssClass="form-label">Main Deal Name</asp:Label>
                    <asp:TextBox ID="txtSetupName" runat="server" CssClass="form-control" placeholder="Enter setup name"></asp:TextBox>
                </div>

                <div class="form-group">
                    <asp:Label runat="server" AssociatedControlID="ddlType" CssClass="form-label">Deal Type</asp:Label>
                    <asp:DropDownList ID="ddlType" runat="server" CssClass="form-control">
                        <asp:ListItem Text="Select Type" Value="0"></asp:ListItem>
                        <asp:ListItem Text="Deal" Value="Deal"></asp:ListItem>
                        <asp:ListItem Text="Additional" Value="Other"></asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>

            <div class="form-group">
                <asp:Label runat="server" CssClass="form-label">Selection Limits</asp:Label>
                <div class="checkbox-group">
                    <div class="checkbox-item">
                        <asp:CheckBox ID="chkAllowOne" runat="server" Text="Allow One Only" />
                    </div>
                    <div class="checkbox-item">
                        <asp:CheckBox ID="chkAllowMany" runat="server" Text="Allow Multiple" />
                    </div>
                </div>
            </div>

            <div style="margin-top: 1.5rem;">
                <asp:Button ID="btnSave" runat="server" Text="Save Deal Setup" CssClass="btn-submit" />
            </div>
        </div>

        <div class="grid-card">
            <h2>Assigned Deals Summary</h2>
            <div class="grid-wrapper" style="margin-top: 1rem;">
                <table id="tblAssignedDeals">
                    <thead>
                        <tr>
                            <th>Sr#</th>
                            <th>Event / Deal</th>
                            <th>Super Name</th>
                            <th>Category</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td colspan="4" style="text-align: center; color: var(--text-muted);">Select an event above to view assigned deals.</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</asp:Content>

