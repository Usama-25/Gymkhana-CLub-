<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master"
AutoEventWireup="true"
CodeFile="Deparmentwiseitems.aspx.cs"
Inherits="Store_Add_Unit"

EnableEventValidation="false"
MaintainScrollPositionOnPostBack="true" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@400;500;600&display=swap" rel="stylesheet">
<style>
  :root {
    --gold:    #f5a623;
    --teal:    #00b4d8;
    --violet:  #7c3aed;
    --rose:    #f43f5e;
    --green:   #10b981;
    --dark:    #0f172a;
    --mid:     #1e293b;
    --glass:   rgba(255,255,255,0.06);
    --border:  rgba(255,255,255,0.12);
  }

  body { background: var(--dark); }

  .page-wrap {
    min-height: 100vh;
    background: linear-gradient(135deg, #0f172a 0%, #1a1040 50%, #0f2a1a 100%);
    padding: 40px 20px 60px;
    font-family: 'DM Sans', sans-serif;
  }

  /* ── Header ── */
  .page-header {
    text-align: center;
    margin-bottom: 36px;
  }
  .page-header .emoji-ring {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 72px; height: 72px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--gold), var(--rose));
    font-size: 36px;
    box-shadow: 0 0 40px rgba(245,166,35,0.4);
    margin-bottom: 14px;
    animation: pulse-ring 2.5s ease-in-out infinite;
  }
  @keyframes pulse-ring {
    0%,100% { box-shadow: 0 0 30px rgba(245,166,35,0.35); }
    50%      { box-shadow: 0 0 60px rgba(245,166,35,0.65); }
  }
  .page-header h1 {
    font-family: 'Playfair Display', serif;
    font-size: 38px;
    background: linear-gradient(90deg, var(--gold), var(--teal), var(--rose));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    margin: 0 0 6px;
    letter-spacing: -0.5px;
  }
  .page-header p {
    color: rgba(255,255,255,0.45);
    font-size: 14px;
    margin: 0;
  }

  /* ── Search Card ── */
  .search-card {
    background: var(--glass);
    border: 1px solid var(--border);
    backdrop-filter: blur(18px);
    border-radius: 20px;
    padding: 28px 32px;
    display: flex;
    align-items: center;
    gap: 16px;
    flex-wrap: wrap;
    max-width: 860px;
    margin: 0 auto 36px;
    box-shadow: 0 8px 40px rgba(0,0,0,0.3);
  }
  .search-card label {
    color: rgba(255,255,255,0.7);
    font-weight: 600;
    font-size: 14px;
    letter-spacing: .5px;
    text-transform: uppercase;
    white-space: nowrap;
  }
  .dropdown {
    flex: 1;
    min-width: 220px;
    padding: 12px 16px;
    border-radius: 12px;
    border: 1.5px solid var(--border);
    background: rgba(255,255,255,0.08);
    color: #fff;
    font-size: 15px;
    font-family: 'DM Sans', sans-serif;
    outline: none;
    transition: border-color .25s, box-shadow .25s;
    cursor: pointer;
  }
  .dropdown:focus {
    border-color: var(--teal);
    box-shadow: 0 0 0 3px rgba(0,180,216,0.25);
  }
  .dropdown option { background: #1e293b; color: #fff; }

  .btnSearch {
    background: linear-gradient(135deg, var(--teal), var(--violet));
    color: #fff;
    border: none;
    padding: 12px 28px;
    border-radius: 12px;
    font-size: 15px;
    font-weight: 600;
    font-family: 'DM Sans', sans-serif;
    cursor: pointer;
    transition: transform .2s, box-shadow .2s;
    box-shadow: 0 4px 20px rgba(124,58,237,0.35);
    white-space: nowrap;
  }
  .btnSearch:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 28px rgba(124,58,237,0.5);
  }
  .btnSearch:active { transform: translateY(0); }

  /* ── Stats Row ── */
  .stats-row {
    display: flex;
    gap: 16px;
    max-width: 860px;
    margin: 0 auto 28px;
    flex-wrap: wrap;
  }
  .stat-pill {
    flex: 1;
    min-width: 140px;
    background: var(--glass);
    border: 1px solid var(--border);
    border-radius: 14px;
    padding: 14px 18px;
    display: flex;
    align-items: center;
    gap: 12px;
    backdrop-filter: blur(12px);
  }
  .stat-pill .dot {
    width: 10px; height: 10px;
    border-radius: 50%;
    flex-shrink: 0;
  }
  .stat-pill .label { color: rgba(255,255,255,0.5); font-size: 12px; }
  .stat-pill .val   { color: #fff; font-size: 22px; font-weight: 700; }

  /* ── Table Wrapper ── */
  .table-wrap {
    max-width: 1100px;
    margin: 0 auto;
    background: var(--glass);
    border: 1px solid var(--border);
    border-radius: 20px;
    overflow: hidden;
    backdrop-filter: blur(18px);
    box-shadow: 0 16px 60px rgba(0,0,0,0.4);
  }

  /* GridView override */
  .grid { border-collapse: collapse; width: 100%; }

  .grid thead tr th {
    padding: 16px 18px;
    text-align: left;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 1.2px;
    text-transform: uppercase;
    color: rgba(255,255,255,0.55);
    border-bottom: 1px solid var(--border);
    background: rgba(255,255,255,0.04);
  }

  .grid tbody tr { transition: background .18s; }
  .grid tbody tr:hover { background: rgba(255,255,255,0.07); }

  .grid tbody tr td {
    padding: 14px 18px;
    border-bottom: 1px solid rgba(255,255,255,0.05);
    font-size: 14px;
    color: rgba(255,255,255,0.88);
    vertical-align: middle;
  }
  .grid tbody tr:last-child td { border-bottom: none; }

  /* Colored badges for specific columns */
  .badge {
    display: inline-block;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
  }
  .badge-price  { background: rgba(16,185,129,0.2);  color: #34d399; border: 1px solid rgba(16,185,129,0.3); }
  .badge-cost   { background: rgba(245,166,35,0.2);  color: #fbbf24; border: 1px solid rgba(245,166,35,0.3); }
  .badge-gst    { background: rgba(124,58,237,0.2);  color: #a78bfa; border: 1px solid rgba(124,58,237,0.3); }
  .badge-dept   { background: rgba(0,180,216,0.15);  color: #38bdf8; border: 1px solid rgba(0,180,216,0.3); }
  .badge-id     { background: rgba(244,63,94,0.15);  color: #fb7185; border: 1px solid rgba(244,63,94,0.3); }

  /* Empty state */
  .empty-state {
    text-align: center;
    padding: 60px 20px;
    color: rgba(255,255,255,0.35);
  }
  .empty-state .empty-icon { font-size: 52px; display: block; margin-bottom: 12px; }
  .empty-state p { font-size: 16px; margin: 0; }

  /* Row animation */
  @keyframes fadeSlideIn {
    from { opacity: 0; transform: translateY(8px); }
    to   { opacity: 1; transform: translateY(0); }
  }
  .grid tbody tr {
    animation: fadeSlideIn .3s ease both;
  }
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="page-wrap">

  <!-- Header -->
  <div class="page-header">
    <div class="emoji-ring">🍽</div>
    <h1>Department-wise Items</h1>
    <p>Browse and filter menu items by department</p>
  </div>

  <!-- Search Card -->
  <div class="search-card">
    <label>Department</label>
    <asp:DropDownList
      ID="ddlDepartment"
      runat="server"
      CssClass="dropdown"
      AutoPostBack="true"
      AppendDataBoundItems="true"
      OnSelectedIndexChanged="ddlDepartment_SelectedIndexChanged">
    </asp:DropDownList>
    <asp:Button
      ID="btnSearch"
      runat="server"
      Text="🔍  Search"
      CssClass="btnSearch"
      OnClick="btnSearch_Click" />
  </div>

  <!-- Stats Row -->
  <div class="stats-row">
    <div class="stat-pill">
      <div class="dot" style="background:var(--rose)"></div>
      <div>
        <div class="label">Total Results</div>
        <div class="val"><asp:Label ID="lblTotal" runat="server" Text="0" /></div>
      </div>
    </div>
    <div class="stat-pill">
      <div class="dot" style="background:var(--green)"></div>
      <div>
        <div class="label">Department</div>
        <div class="val" style="font-size:15px"><asp:Label ID="lblDeptName" runat="server" Text="All" /></div>
      </div>
    </div>
  </div>

  <!-- Grid -->
  <div class="table-wrap">
    <asp:GridView
      ID="gvItems"
      runat="server"
      CssClass="grid"
      AutoGenerateColumns="false"
      GridLines="None"
      EmptyDataText="">
      <Columns>
        <asp:TemplateField HeaderText="ID">
          <ItemTemplate>
            <span class="badge badge-id"><%# Eval("ID") %></span>
          </ItemTemplate>
        </asp:TemplateField>
        <asp:BoundField DataField="ItemName" HeaderText="Item Name" />
        <asp:TemplateField HeaderText="Price">
          <ItemTemplate>
            <span class="badge badge-price">₹ <%# Eval("Price") %></span>
          </ItemTemplate>
        </asp:TemplateField>
        <asp:TemplateField HeaderText="Cost">
          <ItemTemplate>
            <span class="badge badge-cost">₹ <%# Eval("Cost") %></span>
          </ItemTemplate>
        </asp:TemplateField>
        <asp:TemplateField HeaderText="GST %">
          <ItemTemplate>
            <span class="badge badge-gst"><%# Eval("GST") %>%</span>
          </ItemTemplate>
        </asp:TemplateField>
        <asp:TemplateField HeaderText="Dept ID">
          <ItemTemplate>
            <span class="badge badge-dept"><%# Eval("DepartmentID") %></span>
          </ItemTemplate>
        </asp:TemplateField>
      </Columns>
      <EmptyDataTemplate>
        <div class="empty-state">
          <span class="empty-icon">🔍</span>
          <p>No items found. Try selecting a department or click Search to show all.</p>
        </div>
      </EmptyDataTemplate>
    </asp:GridView>
  </div>

</div>
</asp:Content>

