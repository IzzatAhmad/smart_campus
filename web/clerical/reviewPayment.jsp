<%-- reviewPayment.jsp — Clerical Staff: Review a Single Office Payment --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.ClericalStaff"%>
<%@page import="java.util.Map"%>
<%
    ClericalStaff c = (ClericalStaff) session.getAttribute("clerical");
    if (c == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    Map<String, String> p = (Map<String, String>) request.getAttribute("payment");
    if (p == null) {
        response.sendRedirect(request.getContextPath() + "/clerical/payments/monitor");
        return;
    }

    boolean isPending = "PENDING_OFFICE".equals(p.get("payStatus"));
    String currentPage = request.getRequestURI();

    int pendingAppeals = 0; int pendingPayments = 0; int pendingVehicles = 0;
    try {
        pendingAppeals  = new dao.AppealDAO().countPendingAppeals();
        try (java.sql.Connection _con = util.DBConnection.getConnection();
             java.sql.PreparedStatement _ps1 = _con.prepareStatement("SELECT COUNT(*) FROM payment WHERE status='PENDING_OFFICE'");
             java.sql.PreparedStatement _ps2 = _con.prepareStatement("SELECT COUNT(*) FROM vehicle WHERE status='PENDING'")) {
            try (java.sql.ResultSet _rs = _ps1.executeQuery()) { if (_rs.next()) pendingPayments = _rs.getInt(1); }
            try (java.sql.ResultSet _rs = _ps2.executeQuery()) { if (_rs.next()) pendingVehicles = _rs.getInt(1); }
        }
    } catch (Exception _ex) {}
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Review Payment | Smart Campus</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body{margin:0;background:#f5f6fb;font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif}
    .app{min-height:100vh;display:flex}

    /* ── Sidebar ── */
    .sidebar{
      width:260px;background:#f5f0ff;border-right:1px solid #e4d9f7;
      position:fixed;inset:0 auto 0 0;z-index:30;transform:translateX(0);
      transition:transform .25s ease;
      display:flex;flex-direction:column;
    }
    .brand{display:flex;gap:12px;align-items:center;padding:24px 20px 18px}
    .brand-badge{
      width:40px;height:40px;border-radius:12px;background:#7c3aed;color:#fff;
      display:flex;align-items:center;justify-content:center;font-weight:900;font-size:20px;
      box-shadow:0 8px 24px rgba(124,58,237,.30)
    }
    .brand-title{font-weight:900;color:#3b1c86;line-height:1.1}
    .brand-sub{font-size:.75rem;color:#7c3aed;font-weight:700}

    .menu{padding:10px 14px;display:flex;flex-direction:column;gap:4px}
    .menu a{
      text-decoration:none;display:flex;align-items:center;gap:12px;
      padding:11px 14px;border-radius:12px;color:#5b21b6;font-weight:700;
      transition:.15s;
    }
    .menu a:hover{background:#ede9fe;color:#4c1d95}
    .menu a.active{background:#7c3aed;color:#fff;box-shadow:0 4px 14px rgba(124,58,237,.25)}
    .menu a.active svg{opacity:1}
    .menu svg{opacity:.75}
    .menu-label{
      font-size:10px;font-weight:900;letter-spacing:.12em;
      text-transform:uppercase;color:#a78bfa;
      padding:10px 14px 4px;
    }
    .notif-badge{
      margin-left:auto;background:#ef4444;color:#fff;
      font-size:10px;font-weight:950;padding:2px 8px;border-radius:999px;
      display:inline-block;flex-shrink:0;
    }

    .sidebar-bottom{margin-top:auto;padding:14px;border-top:1px solid #e4d9f7}
    .logout-btn{
      width:100%;border:0;background:#f5f0ff;color:#dc2626;font-weight:900;
      padding:12px 14px;border-radius:12px;text-align:left;cursor:pointer;
    }
    .logout-btn:hover{background:#fef2f2}

    /* ── Overlay ── */
    .overlay{position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:20;display:none}
    .overlay.show{display:block}

    /* ── Main ── */
    .main{flex:1;min-width:0;margin-left:260px;display:flex;flex-direction:column;width:calc(100% - 260px)}
    .header{
      height:64px;background:#fff;border-bottom:1px solid #e5e7eb;
      display:flex;align-items:center;justify-content:space-between;
      padding:0 16px;position:sticky;top:0;z-index:10;
    }
    .hamburger{border:0;background:transparent;padding:8px;border-radius:10px}
    .hamburger:hover{background:#f3f4f6}
    .portal-title{font-weight:800;color:#111827}
    .header-right{display:flex;align-items:center;gap:14px}
    .userbox{display:flex;align-items:center;gap:12px;border-left:1px solid #f1f5f9;padding-left:14px}
    .usertext{display:none}
    .avatar{width:40px;height:40px;border-radius:999px;background:#ede9fe;color:#6f3cff;display:flex;align-items:center;justify-content:center;font-weight:900}

    .content{padding:18px 16px 26px}

    /* ── Shared Alerts ── */
    .alert-success{background:#f0fdf4;border:1px solid #bbf7d0;color:#15803d;border-radius:14px;padding:12px 16px;font-weight:700;margin-bottom:16px}
    .alert-error{background:#fef2f2;border:1px solid #fecaca;color:#dc2626;border-radius:14px;padding:12px 16px;font-weight:700;margin-bottom:16px}

    /* ── Shared Pills ── */
    .status-pill{font-size:10px;font-weight:950;text-transform:uppercase;letter-spacing:.08em;padding:5px 10px;border-radius:999px;display:inline-block}
    .pill-unpaid{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}
    .pill-paid{background:#f0fdf4;color:#16a34a;border:1px solid #dcfce7}
    .pill-appealed{background:#eff6ff;color:#2563eb;border:1px solid #dbeafe}
    .pill-overdue{background:#fef2f2;color:#dc2626;border:1px solid #fee2e2}
    .pill-pending{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}
    .type-pill{font-size:10px;font-weight:950;text-transform:uppercase;padding:5px 10px;border-radius:999px;display:inline-block}
    .type-vehicle{background:#eff6ff;color:#2563eb;border:1px solid #dbeafe}
    .type-misconduct{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}

    /* ── Shared Empty State ── */
    .empty-state{text-align:center;padding:48px 20px;color:#9ca3af}
    .empty-state svg{opacity:.3;margin-bottom:12px;display:block;margin-left:auto;margin-right:auto}
    .empty-state p{font-weight:700;font-size:15px;margin:0}

    /* ── Shared Page Header ── */
    .page-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:20px}
    .page-header h1{font-size:22px;font-weight:950;color:#111827;margin:0}
    .page-header p{font-size:13px;color:#6b7280;font-weight:700;margin:4px 0 0}

    /* ── Shared Buttons ── */
    .btn-back{display:inline-flex;align-items:center;gap:8px;background:#f3e8ff;color:#6f3cff;font-weight:900;padding:10px 16px;border-radius:14px;border:0;text-decoration:none}
    .btn-back:hover{background:#ede9fe;color:#6f3cff}
    .btn-purple{background:#6f3cff;border:0;color:#fff;font-weight:900;border-radius:14px;padding:10px 16px;box-shadow:0 12px 26px rgba(111,60,255,.18);display:inline-flex;align-items:center;gap:8px;cursor:pointer}
    .btn-purple:hover{background:#5b21b6;color:#fff}

    /* ── Shared Table Card ── */
    .table-card{background:#fff;border:1px solid #e5e7eb;border-radius:20px;box-shadow:0 4px 12px rgba(17,24,39,.04);overflow:hidden}
    .table-card table{width:100%;border-collapse:collapse;min-width:600px}
    .table-card thead{background:#f9fafb}
    .table-card th{font-size:11px;text-transform:uppercase;letter-spacing:.12em;color:#6b7280;font-weight:950;padding:14px 16px;border-bottom:1px solid #f1f5f9}
    .table-card td{padding:14px 16px;border-bottom:1px solid #f1f5f9;vertical-align:middle}
    .table-card tr:last-child td{border-bottom:0}
    .table-card tr:hover td{background:#fafafa}

    /* ── Shared Filter Bar ── */
    .filter-bar{background:#fff;border:1px solid #e5e7eb;border-radius:18px;padding:14px 18px;margin-bottom:18px;display:flex;align-items:center;gap:12px;flex-wrap:wrap}
    .filter-bar input,.filter-bar select{border:1px solid #e5e7eb;border-radius:10px;padding:8px 12px;font-weight:700;color:#374151;background:#f9fafb;font-size:13px;outline:none}
    .filter-bar input:focus,.filter-bar select:focus{border-color:#6f3cff;background:#fff}

    /* ── Shared Card ── */
    .cardx{background:#fff;border:1px solid #e5e7eb;border-radius:22px;padding:22px;box-shadow:0 4px 12px rgba(17,24,39,.04)}

    /* ── Responsive ── */
    @media(max-width:992px){
      .main{margin-left:0;width:100%}
      .sidebar{transform:translateX(-100%)}
      .sidebar.show{transform:translateX(0)}
      .usertext{display:block}
    }

    /* ── Content ── */
    .content{padding:24px 20px;max-width:760px}

    /* ── Status Banner ── */
    .status-banner-pending{background:linear-gradient(135deg,#fff7ed,#ffedd5);border:1.5px solid #fed7aa;border-radius:16px;padding:16px 20px;display:flex;align-items:center;gap:14px;margin-bottom:24px}
    .status-banner-paid{background:linear-gradient(135deg,#f0fdf4,#dcfce7);border:1.5px solid #bbf7d0;border-radius:16px;padding:16px 20px;display:flex;align-items:center;gap:14px;margin-bottom:24px}
    .banner-icon{width:44px;height:44px;border-radius:14px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
    .banner-icon-pending{background:#ea580c;color:#fff}
    .banner-icon-paid{background:#16a34a;color:#fff}
    .banner-title{font-weight:950;font-size:15px}
    .banner-sub{font-size:12px;font-weight:700;margin-top:2px}
    .banner-pending .banner-title{color:#ea580c}
    .banner-pending .banner-sub{color:#9a3412}
    .banner-paid .banner-title{color:#15803d}
    .banner-paid .banner-sub{color:#166534}

    /* ── Detail Card ── */
    .detail-card{background:#fff;border:1px solid #e5e7eb;border-radius:20px;padding:24px;box-shadow:0 2px 8px rgba(17,24,39,.04);margin-bottom:20px}
    .detail-card-title{font-size:14px;font-weight:950;color:#374151;text-transform:uppercase;letter-spacing:.08em;margin-bottom:18px;padding-bottom:12px;border-bottom:1px solid #f1f5f9}
    .detail-grid{display:grid;grid-template-columns:1fr 1fr;gap:18px}
    .detail-label{font-size:11px;font-weight:900;text-transform:uppercase;letter-spacing:.1em;color:#9ca3af;margin-bottom:4px}
    .detail-value{font-size:14px;font-weight:800;color:#111827}
    .detail-value.amount{font-size:22px;font-weight:950;color:#6f3cff}
    .badge-vehicle{background:#eff6ff;color:#2563eb;font-size:11px;font-weight:900;padding:4px 10px;border-radius:8px}
    .badge-misconduct{background:#fdf4ff;color:#9333ea;font-size:11px;font-weight:900;padding:4px 10px;border-radius:8px}

    /* ── Action Card ── */
    .action-card{background:#fff;border:1px solid #e5e7eb;border-radius:20px;padding:24px;box-shadow:0 2px 8px rgba(17,24,39,.04)}
    .action-card-title{font-size:14px;font-weight:950;color:#374151;text-transform:uppercase;letter-spacing:.08em;margin-bottom:18px;padding-bottom:12px;border-bottom:1px solid #f1f5f9}
    .action-row{display:grid;grid-template-columns:1fr 1fr;gap:14px}
    .btn-verify{width:100%;background:#16a34a;color:#fff;border:0;border-radius:14px;padding:14px;font-weight:950;font-size:15px;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:10px;transition:.15s}
    .btn-verify:hover{background:#15803d}
    .btn-reject{width:100%;background:#dc2626;color:#fff;border:0;border-radius:14px;padding:14px;font-weight:950;font-size:15px;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:10px;transition:.15s}
    .btn-reject:hover{background:#b91c1c}
    .done-notice{background:#f0fdf4;border:1.5px solid #bbf7d0;border-radius:14px;padding:16px 20px;text-align:center;color:#15803d;font-weight:800;font-size:14px}
    @media(max-width:576px){.detail-grid{grid-template-columns:1fr}.action-row{grid-template-columns:1fr}}
  </style>
</head>
<body>
<div id="overlay" class="overlay" onclick="closeSidebar()"></div>

<div class="app">

  <!-- ══════════ SIDEBAR ══════════ -->
      <aside id="sidebar" class="sidebar">
    <div class="brand">
      <div class="brand-badge">U</div>
      <div>
        <div class="brand-title">Smart Campus<br>
          <span class="brand-sub">UMT Disciplinary</span>
        </div>
      </div>
    </div>
    <nav class="menu">
      <div class="menu-label">Main</div>
      <a href="<%=request.getContextPath()%>/clerical/dashboard">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M3 13h8V3H3v10zM13 21h8V11h-8v10zM13 3h8v6h-8V3zM3 21h8v-6H3v6z" stroke="currentColor" stroke-width="2"/></svg>
        Overview
      </a>
      <div class="menu-label">Management</div>
      <a href="<%=request.getContextPath()%>/clerical/vehicle/requests">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z" stroke="currentColor" stroke-width="2"/><path d="M14 2v6h6" stroke="currentColor" stroke-width="2"/></svg>
        Vehicle Approval
        <% if (pendingVehicles > 0) { %><span class="notif-badge"><%= pendingVehicles %></span><% } %>
      </a>
      <a href="<%=request.getContextPath()%>/clerical/summons/list">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M4 4h16v16H4V4z" stroke="currentColor" stroke-width="2"/><path d="M8 8h8M8 12h8M8 16h8" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
        All Summons Records
      </a>
      <a href="<%=request.getContextPath()%>/clerical/offense/list">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M12 9v4m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
        Manage Offense Type
      </a>
      <a href="<%=request.getContextPath()%>/clerical/appeals/list">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z" stroke="currentColor" stroke-width="2" stroke-linejoin="round"/></svg>
        Manage Appeals
        <% if (pendingAppeals > 0) { %><span class="notif-badge"><%= pendingAppeals %></span><% } %>
      </a>
      <div class="menu-label">Monitoring</div>
      <a href="<%=request.getContextPath()%>/clerical/students/list">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2" stroke="currentColor" stroke-width="2"/><circle cx="9" cy="7" r="4" stroke="currentColor" stroke-width="2"/><path d="M23 21v-2a4 4 0 00-3-3.87" stroke="currentColor" stroke-width="2"/><path d="M16 3.13a4 4 0 010 7.75" stroke="currentColor" stroke-width="2"/></svg>
        Student Activity
      </a>
      <a href="<%=request.getContextPath()%>/clerical/patrol/list">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" stroke="currentColor" stroke-width="2"/></svg>
        Patrol Activity Log
      </a>
      <a class="active" href="<%=request.getContextPath()%>/clerical/payments/monitor">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><rect width="20" height="14" x="2" y="5" rx="2" stroke="currentColor" stroke-width="2"/><path d="M2 10h20" stroke="currentColor" stroke-width="2"/></svg>
        Payments Monitoring
        <% if (pendingPayments > 0) { %><span class="notif-badge"><%= pendingPayments %></span><% } %>
      </a>
      <div class="menu-label">Analytics</div>
      <a href="<%=request.getContextPath()%>/clerical/report/view">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M18 20V10M12 20V4M6 20v-6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
        Analytics & Reports
      </a>
    </nav>
    <div class="sidebar-bottom">
      <button class="logout-btn" onclick="window.location.href='<%=request.getContextPath()%>/clerical/logout'">
        <svg style="vertical-align:middle;margin-right:10px" width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4" stroke="currentColor" stroke-width="2"/><path d="M16 17l5-5-5-5" stroke="currentColor" stroke-width="2"/><path d="M21 12H9" stroke="currentColor" stroke-width="2"/></svg>
        Logout
      </button>
    </div>
  </aside>

  <!-- ══════════ MAIN ══════════ -->
  <main class="main">
    <header class="header">
      <button class="hamburger d-lg-none" onclick="openSidebar()">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
          <path d="M4 6h16M4 12h16M4 18h16" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
        </svg>
      </button>
      <div class="portal-title">CLERICAL Portal</div>
      <div class="header-right">
        <div class="userbox">
          <div class="avatar"><%= c.getClericalName().substring(0,1).toUpperCase() %></div>
        </div>
      </div>
    </header>

    <div class="content">

      <!-- Page Header -->
      <div class="page-header">
        <div>
          <h1>Review Payment — <%= p.get("paymentId") %></h1>
          <p>Office payment submitted by student. Verify or reject below.</p>
        </div>
        <a href="<%=request.getContextPath()%>/clerical/payments/monitor" class="btn-back">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
            <path d="M15 18l-6-6 6-6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>
          Back
        </a>
      </div>

      <!-- Status Banner -->
      <% if (isPending) { %>
      <div class="status-banner-pending banner-pending">
        <div class="banner-icon banner-icon-pending">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
            <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/>
            <path d="M12 8v4m0 4h.01" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>
        </div>
        <div>
          <div class="banner-title">Pending Verification</div>
          <div class="banner-sub">Student has declared they will pay at the office. Please confirm once cash is received.</div>
        </div>
      </div>
      <% } else { %>
      <div class="status-banner-paid banner-paid">
        <div class="banner-icon banner-icon-paid">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
            <path d="M20 6L9 17l-5-5" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>
        </div>
        <div>
          <div class="banner-title">Payment Verified</div>
          <div class="banner-sub">This payment has already been confirmed and the summons is marked as PAID.</div>
        </div>
      </div>
      <% } %>

      <!-- Student & Payment Details -->
      <div class="detail-card">
        <div class="detail-card-title">Student Information</div>
        <div class="detail-grid">
          <div class="detail-item">
            <div class="detail-label">Student Name</div>
            <div class="detail-value"><%= p.get("studentName") %></div>
          </div>
          <div class="detail-item">
            <div class="detail-label">Matric No</div>
            <div class="detail-value"><%= p.get("matricNo") %></div>
          </div>
        </div>
      </div>

      <div class="detail-card">
        <div class="detail-card-title">Summons & Payment Details</div>
        <div class="detail-grid">
          <div class="detail-item">
            <div class="detail-label">Payment ID</div>
            <div class="detail-value" style="color:#6f3cff"><%= p.get("paymentId") %></div>
          </div>
          <div class="detail-item">
            <div class="detail-label">Summons ID</div>
            <div class="detail-value"><%= p.get("summonsId") %></div>
          </div>
          <div class="detail-item">
            <div class="detail-label">Offense</div>
            <div class="detail-value"><%= p.get("offenseName") %></div>
          </div>
          <div class="detail-item">
            <div class="detail-label">Type</div>
            <div class="detail-value">
              <% if ("VEHICLE".equals(p.get("summonsType"))) { %>
                <span class="badge-vehicle">Vehicle</span>
              <% } else { %>
                <span class="badge-misconduct">Misconduct</span>
              <% } %>
            </div>
          </div>
          <div class="detail-item">
            <div class="detail-label">Location</div>
            <div class="detail-value"><%= p.get("location") != null ? p.get("location") : "—" %></div>
          </div>
          <div class="detail-item">
            <div class="detail-label">Payment Date</div>
            <div class="detail-value"><%= p.get("paymentDate") %></div>
          </div>
          <div class="detail-item" style="grid-column:1/-1">
            <div class="detail-label">Amount to Collect</div>
            <div class="detail-value amount">RM <%= String.format("%.2f", Double.parseDouble(p.get("paymentAmount"))) %></div>
          </div>
        </div>
      </div>

      <!-- Action Buttons -->
      <div class="action-card">
        <div class="action-card-title">Clerical Action</div>

        <% if (isPending) { %>
        <div class="action-row">
          <!-- VERIFY -->
          <form action="<%=request.getContextPath()%>/clerical/payments/review" method="post"
                onsubmit="return confirmAction('verify', '<%= p.get("paymentId") %>')">
            <input type="hidden" name="paymentId" value="<%= p.get("paymentId") %>"/>
            <input type="hidden" name="summonsId" value="<%= p.get("summonsId") %>"/>
            <input type="hidden" name="action"    value="VERIFY"/>
            <button type="submit" class="btn-verify">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                <path d="M20 6L9 17l-5-5" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/>
              </svg>
              Verify Payment
            </button>
          </form>

          <!-- REJECT -->
          <form action="<%=request.getContextPath()%>/clerical/payments/review" method="post"
                onsubmit="return confirmAction('reject', '<%= p.get("paymentId") %>')">
            <input type="hidden" name="paymentId" value="<%= p.get("paymentId") %>"/>
            <input type="hidden" name="summonsId" value="<%= p.get("summonsId") %>"/>
            <input type="hidden" name="action"    value="REJECT"/>
            <button type="submit" class="btn-reject">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                <path d="M18 6L6 18M6 6l12 12" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/>
              </svg>
              Reject Payment
            </button>
          </form>
        </div>

        <div style="margin-top:14px;font-size:12px;color:#9ca3af;font-weight:700;text-align:center">
          ⚠️ <b>Verify</b> only after cash has been physically received. 
          <b>Reject</b> will reset the summons so the student can re-pay.
        </div>

        <% } else { %>
        <div class="done-notice">
          ✅ This payment is already verified. No further action needed.
        </div>
        <% } %>
      </div>

    </div><!-- end content -->
  </main>
</div>

<script>
  function confirmAction(type, paymentId) {
    if (type === 'verify') {
      return confirm('Confirm: You have received cash for ' + paymentId + '?\nThis will mark the summons as PAID.');
    } else {
      return confirm('Reject payment ' + paymentId + '?\nThe summons will be reset to UNPAID and the student can re-pay.');
    }
  }
  function openSidebar(){
    document.getElementById("sidebar").classList.add("show");
    document.getElementById("overlay").classList.add("show");
  }
  function closeSidebar(){
    document.getElementById("sidebar").classList.remove("show");
    document.getElementById("overlay").classList.remove("show");
  }
</script>
</body>
</html>
