<%@ Page Language="C#" AutoEventWireup="true"
    CodeFile="CancelKot.aspx.cs"
    Inherits="CancelKot" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>KOT Cancellation — Lahore Gymkhana</title>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
<style>
  :root {
    --gold:        #B8962E;
    --gold-light:  #D4AF55;
    --gold-pale:   #F5EDD5;
    --crimson:     #8B1A1A;
    --crimson-dk:  #6B1313;
    --ink:         #1A1A1A;
    --slate:       #3D3D3D;
    --muted:       #6B6B6B;
    --border:      #D6CCB4;
    --surface:     #FDFBF6;
    --surface2:    #F7F3EA;
    --white:       #FFFFFF;
    --danger:      #C0392B;
    --danger-bg:   #FDECEA;
    --success:     #1E7A4A;
    --success-bg:  #E8F5EE;
    --shadow-sm:   0 1px 4px rgba(0,0,0,.08);
    --shadow-md:   0 4px 16px rgba(0,0,0,.10);
    --shadow-lg:   0 8px 32px rgba(0,0,0,.12);
    --radius:      10px;
  }

  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    font-family: 'DM Sans', sans-serif;
    background: #EFEBE0;
    background-image:
      radial-gradient(ellipse at 20% 0%, rgba(184,150,46,.12) 0%, transparent 60%),
      radial-gradient(ellipse at 80% 100%, rgba(139,26,26,.08) 0%, transparent 60%);
    min-height: 100vh;
    color: var(--ink);
    padding: 24px 16px 48px;
  }

  /* ── Page Shell ── */
  .page-shell {
    max-width: 980px;
    margin: 0 auto;
  }

  /* ── Header ── */
  .page-header {
    background: linear-gradient(135deg, var(--crimson) 0%, var(--crimson-dk) 100%);
    border-radius: var(--radius) var(--radius) 0 0;
    padding: 22px 32px 20px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 16px;
    box-shadow: var(--shadow-md);
  }
  .page-header .brand {
    display: flex;
    align-items: center;
    gap: 14px;
  }
  .page-header .crest {
    width: 48px; height: 48px;
    background: var(--gold);
    border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    font-size: 22px;
    flex-shrink: 0;
    box-shadow: 0 2px 8px rgba(0,0,0,.25);
  }
  .page-header .titles h1 {
    font-family: 'Playfair Display', serif;
    font-size: 1.55rem;
    color: var(--white);
    letter-spacing: .02em;
    line-height: 1.1;
  }
  .page-header .titles p {
    font-size: .78rem;
    color: rgba(255,255,255,.65);
    letter-spacing: .12em;
    text-transform: uppercase;
    margin-top: 2px;
  }
  .page-header .kot-badge {
    background: rgba(255,255,255,.12);
    border: 1px solid rgba(255,255,255,.22);
    border-radius: 6px;
    padding: 6px 14px;
    text-align: right;
  }
  .page-header .kot-badge .label {
    font-size: .7rem; color: rgba(255,255,255,.6);
    text-transform: uppercase; letter-spacing: .1em;
  }
  .page-header .kot-badge .value {
    font-family: 'Playfair Display', serif;
    font-size: 1.25rem;
    color: var(--gold-light);
    letter-spacing: .04em;
  }

  /* ── Content Card ── */
  .card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    box-shadow: var(--shadow-sm);
    overflow: hidden;
    margin-bottom: 16px;
  }
  .card:first-of-type { border-radius: 0 0 var(--radius) var(--radius); }

  .card-head {
    background: var(--surface2);
    border-bottom: 1px solid var(--border);
    padding: 13px 24px;
    display: flex;
    align-items: center;
    gap: 10px;
  }
  .card-head .section-num {
    width: 26px; height: 26px;
    background: var(--gold);
    border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    font-size: .7rem;
    font-weight: 700;
    color: var(--white);
    flex-shrink: 0;
  }
  .card-head h2 {
    font-family: 'Playfair Display', serif;
    font-size: 1rem;
    color: var(--crimson);
    font-weight: 600;
    flex: 1;
  }
  .card-head .badge-ro {
    font-size: .68rem;
    background: #E8EDF5;
    color: #4A5878;
    border: 1px solid #C4CEDF;
    border-radius: 4px;
    padding: 2px 8px;
    letter-spacing: .06em;
    text-transform: uppercase;
  }
  .badge-status {
    font-size: .72rem;
    border-radius: 20px;
    padding: 3px 10px;
    font-weight: 600;
    letter-spacing: .04em;
  }
  .badge-status.pending { background: #FFF3CD; color: #856404; border: 1px solid #FFD86B; }
  .badge-status.delivered { background: var(--success-bg); color: var(--success); border: 1px solid #9DD3B5; }

  .card-body { padding: 20px 24px; }

  /* ── KOT Detail Grid ── */
  .detail-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
    gap: 14px 20px;
  }
  .detail-field { display: flex; flex-direction: column; gap: 3px; }
  .detail-field .lbl {
    font-size: .68rem;
    font-weight: 600;
    color: var(--muted);
    text-transform: uppercase;
    letter-spacing: .08em;
  }
  .detail-field .val {
    font-size: .9rem;
    color: var(--ink);
    font-weight: 500;
    background: var(--surface2);
    border: 1px solid var(--border);
    border-radius: 6px;
    padding: 7px 10px;
    min-height: 34px;
    word-break: break-word;
  }
  .detail-field .val.highlight {
    color: var(--crimson);
    font-weight: 700;
    font-size: 1rem;
  }

  /* ── Items Table ── */
  .items-table {
    width: 100%;
    border-collapse: collapse;
    font-size: .875rem;
  }
  .items-table thead tr {
    background: linear-gradient(135deg, var(--crimson) 0%, var(--crimson-dk) 100%);
  }
  .items-table thead th {
    color: var(--white);
    font-weight: 600;
    letter-spacing: .06em;
    font-size: .72rem;
    text-transform: uppercase;
    padding: 10px 14px;
    text-align: left;
  }
  .items-table thead th:last-child { text-align: right; }
  .items-table tbody tr { border-bottom: 1px solid var(--border); transition: background .15s; }
  .items-table tbody tr:hover { background: var(--surface2); }
  .items-table tbody tr:last-child { border-bottom: none; }
  .items-table tbody td {
    padding: 10px 14px;
    color: var(--slate);
    vertical-align: middle;
  }
  .items-table tbody td.right { text-align: right; }
  .items-table tbody td.amt { font-weight: 600; color: var(--ink); }
  .items-table .item-name { font-weight: 500; color: var(--ink); }
  .tfoot-total {
    background: var(--gold-pale);
    border-top: 2px solid var(--gold);
  }
  .tfoot-total td {
    padding: 11px 14px;
    font-weight: 700;
    font-size: .95rem;
    color: var(--crimson);
  }
  .tfoot-total td:last-child { text-align: right; }

  .empty-items {
    text-align: center;
    padding: 32px;
    color: var(--muted);
    font-size: .9rem;
    font-style: italic;
  }

  /* ── Form Controls ── */
  .form-group { margin-bottom: 0; }
  .form-group label {
    display: block;
    font-size: .8rem;
    font-weight: 600;
    color: var(--slate);
    margin-bottom: 6px;
    letter-spacing: .04em;
  }
  .form-group label .req { color: var(--danger); margin-left: 3px; }
  .form-group label .min-note {
    font-size: .7rem;
    font-weight: 400;
    color: var(--muted);
    margin-left: 6px;
  }
  .form-group textarea {
    width: 100%;
    min-height: 120px;
    resize: vertical;
    border: 1.5px solid var(--border);
    border-radius: 8px;
    padding: 12px 14px;
    font-family: 'DM Sans', sans-serif;
    font-size: .875rem;
    color: var(--ink);
    background: var(--white);
    transition: border-color .2s, box-shadow .2s;
    outline: none;
    line-height: 1.55;
  }
  .form-group textarea:focus {
    border-color: var(--gold);
    box-shadow: 0 0 0 3px rgba(184,150,46,.15);
  }
  .form-group textarea.error-field {
    border-color: var(--danger);
    box-shadow: 0 0 0 3px rgba(192,57,43,.12);
  }
  .char-counter {
    font-size: .7rem;
    color: var(--muted);
    margin-top: 5px;
    text-align: right;
    transition: color .2s;
  }
  .char-counter.ok { color: var(--success); font-weight: 600; }
  .char-counter.warn { color: var(--gold); font-weight: 600; }
  .field-error {
    font-size: .75rem;
    color: var(--danger);
    margin-top: 5px;
    display: none;
    align-items: center;
    gap: 4px;
  }
  .field-error.visible { display: flex; }

  /* ── Verification ── */
  .verify-box {
    background: #FFF8EC;
    border: 1.5px solid var(--gold);
    border-radius: 8px;
    padding: 16px 20px;
  }
  .verify-check {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    cursor: pointer;
  }
  .verify-check input[type="checkbox"] {
    width: 20px; height: 20px;
    margin-top: 1px;
    accent-color: var(--crimson);
    cursor: pointer;
    flex-shrink: 0;
  }
  .verify-check .verify-text {
    font-size: .9rem;
    color: var(--ink);
    font-weight: 500;
    line-height: 1.4;
    user-select: none;
  }
  .verify-check .verify-text strong { color: var(--crimson); }

  /* ── Audit Panel ── */
  .audit-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
  }
  .audit-field { display: flex; flex-direction: column; gap: 4px; }
  .audit-field .lbl {
    font-size: .7rem;
    font-weight: 600;
    color: var(--muted);
    text-transform: uppercase;
    letter-spacing: .08em;
  }
  .audit-field .val {
    font-size: .88rem;
    color: var(--ink);
    font-weight: 600;
    background: #F0F4F8;
    border: 1px solid #C9D4E0;
    border-radius: 6px;
    padding: 8px 12px;
  }
  .audit-field .val .sub {
    font-size: .75rem;
    color: var(--muted);
    font-weight: 400;
    margin-top: 1px;
  }

  /* ── Alert Banners ── */
  .alert {
    border-radius: 8px;
    padding: 13px 16px;
    margin-bottom: 16px;
    display: flex;
    align-items: flex-start;
    gap: 10px;
    font-size: .85rem;
    display: none;
  }
  .alert.visible { display: flex; }
  .alert-danger { background: var(--danger-bg); border: 1px solid #F1A8A8; color: #7B1818; }
  .alert-success { background: var(--success-bg); border: 1px solid #9DD3B5; color: #154C30; }
  .alert .alert-icon { font-size: 1.1rem; flex-shrink: 0; margin-top: 1px; }

  /* ── Action Buttons ── */
  .action-bar {
    display: flex;
    align-items: center;
    justify-content: flex-end;
    gap: 12px;
    padding: 20px 24px;
    background: var(--surface2);
    border-top: 1px solid var(--border);
    border-radius: 0 0 var(--radius) var(--radius);
  }
  .btn {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    border: none;
    border-radius: 8px;
    padding: 11px 26px;
    font-family: 'DM Sans', sans-serif;
    font-size: .9rem;
    font-weight: 600;
    cursor: pointer;
    transition: all .2s;
    letter-spacing: .02em;
    text-decoration: none;
  }
  .btn-cancel-kot {
    background: linear-gradient(135deg, var(--danger) 0%, #A52A2A 100%);
    color: var(--white);
    box-shadow: 0 2px 8px rgba(192,57,43,.35);
  }
  .btn-cancel-kot:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 14px rgba(192,57,43,.45);
  }
  .btn-cancel-kot:active { transform: translateY(0); }
  .btn-cancel-kot:disabled {
    opacity: .5;
    cursor: not-allowed;
    transform: none;
    box-shadow: none;
  }
  .btn-close {
    background: #6B7280;
    color: var(--white);
    box-shadow: 0 2px 6px rgba(0,0,0,.15);
  }
  .btn-close:hover { background: #4B5563; transform: translateY(-1px); }
  .btn-close:active { transform: translateY(0); }

  /* ── Divider ── */
  .section-gap { margin-bottom: 16px; }

  /* ── Overlay / Loading ── */
  .overlay {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,.45);
    z-index: 999;
    align-items: center;
    justify-content: center;
  }
  .overlay.visible { display: flex; }
  .spinner {
    width: 48px; height: 48px;
    border: 4px solid rgba(255,255,255,.25);
    border-top-color: var(--gold-light);
    border-radius: 50%;
    animation: spin .7s linear infinite;
  }
  @keyframes spin { to { transform: rotate(360deg); } }

  /* ── Confirm Modal ── */
  .modal-wrap {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,.5);
    z-index: 1000;
    align-items: center;
    justify-content: center;
    padding: 16px;
  }
  .modal-wrap.visible { display: flex; }
  .modal {
    background: var(--white);
    border-radius: 12px;
    max-width: 440px;
    width: 100%;
    box-shadow: var(--shadow-lg);
    animation: slideUp .25s ease;
    overflow: hidden;
  }
  @keyframes slideUp {
    from { transform: translateY(24px); opacity: 0; }
    to   { transform: translateY(0);    opacity: 1; }
  }
  .modal-header {
    background: linear-gradient(135deg, var(--danger) 0%, #A52A2A 100%);
    padding: 18px 24px;
    display: flex;
    align-items: center;
    gap: 10px;
  }
  .modal-header h3 {
    font-family: 'Playfair Display', serif;
    color: var(--white);
    font-size: 1.1rem;
  }
  .modal-header .modal-icon { font-size: 1.4rem; }
  .modal-body { padding: 22px 24px; }
  .modal-body p { font-size: .9rem; color: var(--slate); line-height: 1.55; }
  .modal-body p strong { color: var(--ink); }
  .modal-body .warn-note {
    background: var(--danger-bg);
    border-left: 3px solid var(--danger);
    padding: 10px 14px;
    margin-top: 14px;
    font-size: .82rem;
    color: #7B1818;
    border-radius: 0 6px 6px 0;
  }
  .modal-footer {
    display: flex;
    gap: 10px;
    padding: 16px 24px 20px;
    justify-content: flex-end;
    border-top: 1px solid var(--border);
  }
  .btn-sm { padding: 9px 20px; font-size: .85rem; }

  /* ── Responsive ── */
  @media (max-width: 640px) {
    .page-header { flex-direction: column; align-items: flex-start; gap: 12px; }
    .page-header .kot-badge { align-self: flex-start; }
    .detail-grid { grid-template-columns: 1fr 1fr; }
    .audit-grid { grid-template-columns: 1fr; }
    .card-body { padding: 16px; }
    .action-bar { flex-direction: column-reverse; }
    .btn { width: 100%; justify-content: center; }
    .items-table { font-size: .8rem; }
    .items-table thead th, .items-table tbody td { padding: 8px 10px; }
  }
  @media (max-width: 400px) {
    .detail-grid { grid-template-columns: 1fr; }
  }
</style>
</head>
<body>
<div class="overlay" id="loadingOverlay"><div class="spinner"></div></div>

<!-- Confirm Modal -->
<div class="modal-wrap" id="confirmModal">
  <div class="modal">
    <div class="modal-header">
      <span class="modal-icon">⚠️</span>
      <h3>Confirm KOT Cancellation</h3>
    </div>
    <div class="modal-body">
      <p>You are about to cancel <strong>KOT #<span id="modalKotNo"></span></strong> for <strong><span id="modalMember"></span></strong>.</p>
      <p style="margin-top:8px;">This action is <strong>irreversible</strong> and will be permanently recorded in the audit log.</p>
      <div class="warn-note">
        ⚠️ Ensure all information is accurate before proceeding. Cancellation records are subject to management review.
      </div>
    </div>
    <div class="modal-footer">
      <button class="btn btn-close btn-sm" onclick="closeModal()">Cancel</button>
      <button class="btn btn-cancel-kot btn-sm" id="btnConfirmFinal" onclick="executeCancellation()">✓ Confirm Cancellation</button>
    </div>
  </div>
</div>

<form id="cancelKotForm" runat="server" method="post">
<asp:HiddenField ID="hfBillId"    runat="server" />
<asp:HiddenField ID="hfKotNumber" runat="server" />

<div class="page-shell">

  <!-- ══ HEADER ══ -->
  <div class="page-header">
    <div class="brand">
      <div class="crest">🏛️</div>
      <div class="titles">
        <h1>KOT Cancellation</h1>
        <p>Lahore Gymkhana · Restaurant Management System</p>
      </div>
    </div>
    <div class="kot-badge">
      <div class="label">KOT Number</div>
      <div class="value" id="headerKotNo">—</div>
    </div>
  </div>

  <!-- ══ ALERT BANNER ══ -->
  <div class="alert alert-danger" id="alertError">
    <span class="alert-icon">🚫</span>
    <div id="alertErrorMsg">Please correct the errors below before proceeding.</div>
  </div>
  <div class="alert alert-success" id="alertSuccess">
    <span class="alert-icon">✅</span>
    <div id="alertSuccessMsg">KOT has been successfully cancelled and audit record saved.</div>
  </div>

  <!-- ══ SECTION 1 — KOT DETAILS ══ -->
  <div class="card section-gap">
    <div class="card-head">
      <div class="section-num">1</div>
      <h2>KOT Details</h2>
      <span class="badge-ro">Read Only</span>
      <span class="badge-status pending" id="kotStatusBadge" style="margin-left:auto">Pending</span>
    </div>
    <div class="card-body">
      <div class="detail-grid">
        <div class="detail-field">
          <span class="lbl">KOT Number</span>
          <span class="val" id="d_KotNumber">—</span>
        </div>
        <div class="detail-field">
          <span class="lbl">Bill Number</span>
          <span class="val" id="d_BillNumber">—</span>
        </div>
        <div class="detail-field">
          <span class="lbl">KOT Date &amp; Time</span>
          <span class="val" id="d_KotDateTime">—</span>
        </div>
        <div class="detail-field">
          <span class="lbl">Member Number</span>
          <span class="val" id="d_MemberNo">—</span>
        </div>
        <div class="detail-field">
          <span class="lbl">Member Name</span>
          <span class="val" id="d_MemberName">—</span>
        </div>
        <div class="detail-field">
          <span class="lbl">Table Number</span>
          <span class="val" id="d_TableNumber">—</span>
        </div>
        <div class="detail-field">
          <span class="lbl">Department</span>
          <span class="val" id="d_Department">—</span>
        </div>
        <div class="detail-field">
          <span class="lbl">Waiter Name</span>
          <span class="val" id="d_WaiterName">—</span>
        </div>
        <div class="detail-field">
          <span class="lbl">Room Number</span>
          <span class="val" id="d_RoomNo">—</span>
        </div>
        <div class="detail-field">
          <span class="lbl">Bill To</span>
          <span class="val" id="d_BillTo">—</span>
        </div>
        <div class="detail-field">
          <span class="lbl">Cover</span>
          <span class="val" id="d_Cover">—</span>
        </div>
        <div class="detail-field">
          <span class="lbl">KOT Status</span>
          <span class="val" id="d_Status">—</span>
        </div>
        <div class="detail-field" style="grid-column: span 2;">
          <span class="lbl">Subtotal Amount</span>
          <span class="val highlight" id="d_Subtotal">PKR —</span>
        </div>
      </div>
    </div>
  </div>

  <!-- ══ SECTION 2 — ORDERED ITEMS ══ -->
  <div class="card section-gap">
    <div class="card-head">
      <div class="section-num">2</div>
      <h2>Ordered Items</h2>
    </div>
    <div class="card-body" style="padding:0;">
      <div style="overflow-x:auto;">
        <table class="items-table">
          <thead>
            <tr>
              <th>#</th>
              <th>Item Name</th>
              <th style="text-align:right">Qty</th>
              <th style="text-align:right">Rate (PKR)</th>
              <th style="text-align:right">Amount (PKR)</th>
            </tr>
          </thead>
          <tbody id="itemsBody">
            <tr><td colspan="5" class="empty-items">Loading items…</td></tr>
          </tbody>
          <tfoot>
            <tr class="tfoot-total">
              <td colspan="4" style="text-align:right; letter-spacing:.06em; text-transform:uppercase; font-size:.78rem;">Total Amount</td>
              <td id="tfoot_Total" style="text-align:right; font-size:1rem;">PKR 0.00</td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
  </div>

  <!-- ══ SECTION 3 — MEMBER COMPLAINT ══ -->
  <div class="card section-gap">
    <div class="card-head">
      <div class="section-num">3</div>
      <h2>Member Complaint / Cancellation Reason</h2>
    </div>
    <div class="card-body">
      <div class="form-group">
        <label for="txtMemberReason">
          Member Complaint / Cancellation Reason
          <span class="req">*</span>
          <span class="min-note">(min. 30 characters required)</span>
        </label>
        <asp:TextBox ID="txtMemberReason" runat="server"
          TextMode="MultiLine"
          CssClass="form-control"
          placeholder="Please enter complete details of the member's complaint or reason for cancellation. Include what occurred, when it occurred, and the member's specific objection or complaint regarding this order."
          Rows="5"
          ClientIDMode="Static" />
        <div class="char-counter" id="counter_Member">0 / 30 characters minimum</div>
        <div class="field-error" id="err_MemberReason">
          <span>⚠</span> <span id="err_MemberReason_Msg">Please provide a detailed cancellation reason (minimum 30 characters).</span>
        </div>
      </div>
    </div>
  </div>

  <!-- ══ SECTION 4 — MANAGEMENT APPROVAL ══ -->
  <div class="card section-gap">
    <div class="card-head">
      <div class="section-num">4</div>
      <h2>Management Approval Remarks</h2>
    </div>
    <div class="card-body">
      <div class="form-group">
        <label for="txtManagerRemarks">
          Management Approval Remarks
          <span class="req">*</span>
          <span class="min-note">(min. 25 characters required)</span>
        </label>
        <asp:TextBox ID="txtManagerRemarks" runat="server"
          TextMode="MultiLine"
          CssClass="form-control"
          placeholder="Enter management verification and approval remarks. State the basis for approval, any investigation conducted, and confirmation that the cancellation is authorised."
          Rows="4"
          ClientIDMode="Static" />
        <div class="char-counter" id="counter_Manager">0 / 25 characters minimum</div>
        <div class="field-error" id="err_ManagerRemarks">
          <span>⚠</span> <span id="err_ManagerRemarks_Msg">Please provide management approval remarks (minimum 25 characters).</span>
        </div>
      </div>
    </div>
  </div>

  <!-- ══ SECTION 5 — VERIFICATION ══ -->
  <div class="card section-gap">
    <div class="card-head">
      <div class="section-num">5</div>
      <h2>Verification</h2>
    </div>
    <div class="card-body">
      <div class="verify-box">
        <label class="verify-check" for="chkVerify">
          <asp:CheckBox ID="chkVerify" runat="server" ClientIDMode="Static" />
          <span class="verify-text">
            I confirm that the <strong>member's request/complaint has been verified</strong> and the cancellation is approved by authorised management. I understand this action is <strong>irreversible and will be fully audited</strong>.
          </span>
        </label>
        <div class="field-error" id="err_Verify" style="margin-top:8px;">
          <span>⚠</span> <span>You must verify and confirm before cancellation is allowed.</span>
        </div>
      </div>
    </div>
  </div>

  <!-- ══ SECTION 6 — AUDIT INFORMATION ══ -->
  <div class="card section-gap">
    <div class="card-head">
      <div class="section-num">6</div>
      <h2>Audit Information</h2>
    </div>
    <div class="card-body">
      <div class="audit-grid">
        <div class="audit-field">
          <span class="lbl">🔐 Cancelled By (Logged-In User)</span>
          <div class="val">
            <span id="auditUser">—</span>
            <div class="sub" id="auditEmpId"></div>
          </div>
        </div>
        <div class="audit-field">
          <span class="lbl">🕐 Cancellation Date &amp; Time</span>
          <div class="val">
            <span id="auditDateTime">—</span>
            <div class="sub">System timestamp (auto-generated)</div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- ══ SECTION 7 — ACTION BUTTONS ══ -->
  <div class="card">
    <div class="action-bar">
      <asp:Button ID="btnClose" runat="server" Text="✕  Close"
        CssClass="btn btn-close"
        OnClientClick="window.close(); return false;"
        UseSubmitBehavior="false" />
      <asp:Button ID="btnCancelKOT" runat="server" Text="⊘  Cancel KOT"
        CssClass="btn btn-cancel-kot"
        OnClientClick="return validateAndConfirm();"
        OnClick="btnCancelKOT_Click" />
    </div>
  </div>

</div><!-- /page-shell -->
</form>

<script>
  /* ── Vague words to reject ── */
  const VAGUE = ['ok','okay','cancel','done','cancelled','yes','no','na','n/a','...',
                 'nothing','nil','none','fine','sure','agreed','approved','noted','see','check'];

  /* ── Populate KOT header badge ── */
  function setHeaderKot(val) {
    document.getElementById('headerKotNo').textContent = val || '—';
  }

  /* ── Set status badge ── */
  function setStatusBadge(status) {
    const b = document.getElementById('kotStatusBadge');
    b.textContent = status;
    b.className = 'badge-status ' + (status === 'Delivered' ? 'delivered' : 'pending');
  }

  /* ── Set detail field ── */
  function setDetail(id, val) {
    const el = document.getElementById(id);
    if (el) el.textContent = val || '—';
  }

  /* ── Render items ── */
  function renderItems(items) {
    const tbody = document.getElementById('itemsBody');
    if (!items || items.length === 0) {
      tbody.innerHTML = '<tr><td colspan="5" class="empty-items">No items found for this KOT.</td></tr>';
      document.getElementById('tfoot_Total').textContent = 'PKR 0.00';
      return;
    }
    let html = '', total = 0;
    items.forEach((it, i) => {
      const amt = parseFloat(it.LineTotal || 0);
      total += amt;
      html += `<tr>
        <td>${i + 1}</td>
        <td class="item-name">${esc(it.Name)}</td>
        <td class="right">${it.Quantity}</td>
        <td class="right">${fmt(it.Price)}</td>
        <td class="right amt">${fmt(amt)}</td>
      </tr>`;
    });
    tbody.innerHTML = html;
    document.getElementById('tfoot_Total').textContent = 'PKR ' + total.toLocaleString('en-PK', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  }

  function fmt(n) {
    return parseFloat(n || 0).toLocaleString('en-PK', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  }
  function esc(s) {
    const d = document.createElement('div');
    d.textContent = s;
    return d.innerHTML;
  }

  /* ── Live character counters ── */
  function wireCounter(textareaId, counterId, minLen) {
    const ta = document.getElementById(textareaId);
    const ctr = document.getElementById(counterId);
    if (!ta || !ctr) return;
    ta.addEventListener('input', function() {
      const len = ta.value.trim().length;
      ctr.textContent = len + ' / ' + minLen + ' characters minimum';
      if (len >= minLen) { ctr.className = 'char-counter ok'; }
      else if (len > 0)  { ctr.className = 'char-counter warn'; }
      else               { ctr.className = 'char-counter'; }
    });
  }
  wireCounter('txtMemberReason',  'counter_Member',  30);
  wireCounter('txtManagerRemarks','counter_Manager', 25);

  /* ── Live clock for audit ── */
  function tickClock() {
    const now = new Date();
    const opts = { year:'numeric', month:'short', day:'2-digit',
                   hour:'2-digit', minute:'2-digit', second:'2-digit', hour12:true };
    document.getElementById('auditDateTime').textContent =
      now.toLocaleString('en-PK', opts);
  }
  tickClock();
  setInterval(tickClock, 1000);

  /* ── Vague check ── */
  function isVague(str) {
    const clean = str.trim().toLowerCase().replace(/[^a-z0-9 ]/g,'').replace(/\s+/g,' ');
    return VAGUE.includes(clean) || /^[.\-_ ]+$/.test(str.trim());
  }

  /* ── Show / hide field errors ── */
  function showErr(id, msg) {
    const el = document.getElementById(id);
    if (!el) return;
    el.classList.add('visible');
    if (msg) {
      const msgEl = document.getElementById(id + '_Msg');
      if (msgEl) msgEl.textContent = msg;
    }
  }
  function clearErr(id) {
    const el = document.getElementById(id);
    if (el) el.classList.remove('visible');
  }

  /* ── Client-side validation ── */
  function validateForm() {
    let valid = true;
    clearErr('err_MemberReason');
    clearErr('err_ManagerRemarks');
    clearErr('err_Verify');
    document.getElementById('alertError').classList.remove('visible');

    const reason = document.getElementById('txtMemberReason').value.trim();
    const remarks = document.getElementById('txtManagerRemarks').value.trim();
    const verified = document.getElementById('chkVerify_0') || document.getElementById('chkVerify');
    const isChecked = verified ? verified.checked : false;

    // Member reason
    if (reason.length === 0) {
      showErr('err_MemberReason', 'Member complaint / cancellation reason is mandatory.');
      document.getElementById('txtMemberReason').classList.add('error-field');
      valid = false;
    } else if (reason.length < 30) {
      showErr('err_MemberReason', 'Please provide at least 30 characters for the cancellation reason.');
      document.getElementById('txtMemberReason').classList.add('error-field');
      valid = false;
    } else if (isVague(reason)) {
      showErr('err_MemberReason', 'Vague remarks are not accepted. Please provide complete details.');
      document.getElementById('txtMemberReason').classList.add('error-field');
      valid = false;
    } else {
      document.getElementById('txtMemberReason').classList.remove('error-field');
    }

    // Manager remarks
    if (remarks.length === 0) {
      showErr('err_ManagerRemarks', 'Management approval remarks are mandatory.');
      document.getElementById('txtManagerRemarks').classList.add('error-field');
      valid = false;
    } else if (remarks.length < 25) {
      showErr('err_ManagerRemarks', 'Please provide at least 25 characters for management remarks.');
      document.getElementById('txtManagerRemarks').classList.add('error-field');
      valid = false;
    } else if (isVague(remarks)) {
      showErr('err_ManagerRemarks', 'Vague remarks are not accepted. Please provide complete approval justification.');
      document.getElementById('txtManagerRemarks').classList.add('error-field');
      valid = false;
    } else {
      document.getElementById('txtManagerRemarks').classList.remove('error-field');
    }

    // Verification checkbox
    if (!isChecked) {
      showErr('err_Verify', null);
      valid = false;
    }

    if (!valid) {
      const alertEl = document.getElementById('alertError');
      alertEl.classList.add('visible');
      alertEl.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
    return valid;
  }

  /* ── Open confirm modal ── */
  function validateAndConfirm() {
    if (!validateForm()) return false;
    const kotNo = document.getElementById('d_KotNumber').textContent;
    const member = document.getElementById('d_MemberName').textContent;
    document.getElementById('modalKotNo').textContent = kotNo;
    document.getElementById('modalMember').textContent = member;
    document.getElementById('confirmModal').classList.add('visible');
    return false; // Prevent postback until confirmed
  }

  /* ── Close modal ── */
  function closeModal() {
    document.getElementById('confirmModal').classList.remove('visible');
  }

  /* ── Execute: trigger the ASP.NET button programmatically ── */
  function executeCancellation() {
    closeModal();
    document.getElementById('loadingOverlay').classList.add('visible');
    // Trigger the server-side button click
    __doPostBack('<%= btnCancelKOT.UniqueID %>', '');
  }

  /* ── Populate page data (called from code-behind via RegisterStartupScript) ── */
  function populateKotData(data) {
    setDetail('d_KotNumber',  data.kotNumber);
    setDetail('d_BillNumber', data.billNo);
    setDetail('d_KotDateTime',data.createdAt);
    setDetail('d_MemberNo',   data.memberNo);
    setDetail('d_MemberName', data.memberName);
    setDetail('d_TableNumber',data.tableNumber);
    setDetail('d_Department', data.deptName);
    setDetail('d_WaiterName', data.waiterName);
    setDetail('d_RoomNo',     data.roomNo);
    setDetail('d_BillTo',     data.billTo);
    setDetail('d_Cover',      data.cover);
    setDetail('d_Status',     data.status);
    setDetail('d_Subtotal',   'PKR ' + parseFloat(data.subtotal || 0).toLocaleString('en-PK', {minimumFractionDigits:2, maximumFractionDigits:2}));
    setHeaderKot(data.kotNumber);
    setStatusBadge(data.status || 'Pending');
    document.getElementById('auditUser').textContent  = data.cancelledBy || '—';
    document.getElementById('auditEmpId').textContent = data.empId ? 'Employee ID: ' + data.empId : '';
    renderItems(data.items || []);
  }
</script>
</body>
</html>
