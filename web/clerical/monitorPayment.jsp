<%-- monitorPayment.jsp — Clerical Staff: Monitor Office Payments --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.ClericalStaff"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%
    ClericalStaff c = (ClericalStaff) session.getAttribute("clerical");
    if (c == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<Map<String, String>> payments =
        (List<Map<String, String>>) request.getAttribute("payments");

    long   countPending   = (Long)   request.getAttribute("countPending");
    long   countVerified  = (Long)   request.getAttribute("countVerified");
    String totalCollected = (String) request.getAttribute("totalCollected");

    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg   = (String) session.getAttribute("errorMsg");
    session.removeAttribute("successMsg");
    session.removeAttribute("errorMsg");

    // Optional filter from URL ?filter=ALL|PENDING_OFFICE|PAID
    String filter = request.getParameter("filter");
    if (filter == null || filter.isBlank()) filter = "ALL";

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
  <title>Payments Monitoring | Smart Campus</title>
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
    .table-wrap{overflow-x:auto}
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

    /* ── Content ── */
    .content{padding:24px 20px}

    /* ── Stat Cards ── */
    .stat-row{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin-bottom:24px}
    .stat-card{background:#fff;border:1px solid #e5e7eb;border-radius:18px;padding:20px 22px;box-shadow:0 2px 8px rgba(17,24,39,.04)}
    .stat-label{font-size:11px;font-weight:900;text-transform:uppercase;letter-spacing:.1em;color:#9ca3af;margin-bottom:6px}
    
    /* Nilai Stat dioptimumkan saiznya dan dikawal jika melimpah */
    .stat-value{
      font-size:26px;
      font-weight:950;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .stat-pending .stat-value{color:#ea580c}
    .stat-verified .stat-value{color:#16a34a}
    .stat-total .stat-value{color:#6f3cff}
    .stat-sub{font-size:12px;font-weight:700;color:#9ca3af;margin-top:4px}

    /* ── Filter Pills ── */
    .filter-pills{display:flex;gap:8px;margin-bottom:18px;flex-wrap:wrap}
    .filter-pill{text-decoration:none;font-size:12px;font-weight:800;padding:7px 16px;border-radius:10px;border:1.5px solid #e5e7eb;background:#fff;color:#6b7280;transition:.15s}
    .filter-pill:hover{border-color:#6f3cff;color:#6f3cff}
    .filter-pill.active{border-color:#6f3cff;background:#f3e8ff;color:#6f3cff}

    /* ── Badges ── */
    .badge-pending{background:#fff7ed;color:#ea580c;font-size:11px;font-weight:900;padding:4px 10px;border-radius:8px;white-space:nowrap}
    .badge-paid{background:#f0fdf4;color:#16a34a;font-size:11px;font-weight:900;padding:4px 10px;border-radius:8px;white-space:nowrap}
    .badge-vehicle{background:#eff6ff;color:#2563eb;font-size:11px;font-weight:900;padding:4px 10px;border-radius:8px}
    .badge-misconduct{background:#fdf4ff;color:#9333ea;font-size:11px;font-weight:900;padding:4px 10px;border-radius:8px}

    /* ── Review Button ── */
    .btn-review{background:#6f3cff;color:#fff;border:0;border-radius:10px;padding:7px 16px;font-weight:900;font-size:12px;cursor:pointer;text-decoration:none;white-space:nowrap;display:inline-block;transition:.15s}
    .btn-review:hover{background:#5b21b6;color:#fff}

    /* ── Responsive Tablet & Mobile ── */
    @media(max-width:992px){
      .main{margin-left:0;width:100%}
      .sidebar{transform:translateX(-100%)}
      .sidebar.show{transform:translateX(0)}
      .stat-row{grid-template-columns:1fr 1fr}
      .usertext{display:block}
    }

    /* Breakpoint tambahan khusus untuk Skrin Kecil / Telefon */
    @media(max-width:576px){
      .stat-row {
        grid-template-columns: 1fr; /* Tukar kad kepada susunan menegak */
        gap: 12px;
      }
      .stat-value {
        font-size: 24px; /* Kecilkan saiz font sedikit lagi supaya muat elok */
      }
    }
  </style>
</head>
<body>
<div id="overlay" class="overlay" onclick="closeSidebar()"></div>

<div class="app">

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

      <% if (successMsg != null) { %>
        <div class="alert-success">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
            <path d="M20 6L9 17l-5-5" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>
          <%= successMsg %>
        </div>
      <% } %>
      <% if (errorMsg != null) { %>
        <div class="alert-error">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
            <path d="M18 6L6 18M6 6l12 12" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>
          <%= errorMsg %>
        </div>
      <% } %>

      <div class="page-header">
        <h1>Payments Monitoring</h1>
        <p>Verify and manage student office payments.</p>
      </div>

      <div class="stat-row">
        <div class="stat-card stat-pending">
          <div class="stat-label">Pending Verification</div>
          <div class="stat-value"><%= countPending %></div>
          <div class="stat-sub">Awaiting office confirmation</div>
        </div>
        <div class="stat-card stat-verified">
          <div class="stat-label">Verified</div>
          <div class="stat-value"><%= countVerified %></div>
          <div class="stat-sub">Payments confirmed</div>
        </div>
        <div class="stat-card stat-total">
          <div class="stat-label">Total Collected</div>
          <div class="stat-value">RM <%= totalCollected %></div>
          <div class="stat-sub">From office payments</div>
        </div>
      </div>

      <div class="filter-bar">
        <a href="?filter=ALL"
           class="filter-pill <%= "ALL".equals(filter) ? "active" : "" %>">All</a>
        <a href="?filter=PENDING_OFFICE"
           class="filter-pill <%= "PENDING_OFFICE".equals(filter) ? "active" : "" %>">Pending</a>
        <a href="?filter=PAID"
           class="filter-pill <%= "PAID".equals(filter) ? "active" : "" %>">Verified</a>
      </div>

      <div class="table-card">
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Payment ID</th>
                <th>Summons ID</th>
                <th>Student</th>
                <th>Type</th>
                <th>Amount</th>
                <th>Date</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              <%
                boolean hasRows = false;
                if (payments != null) {
                  for (Map<String, String> p : payments) {
                    String payStatus  = p.get("payStatus");
                    // Apply filter
                    if (!"ALL".equals(filter) && !filter.equals(payStatus)) continue;
                    hasRows = true;
              %>
              <tr>
                <td style="font-weight:950;color:#6f3cff"><%= p.get("paymentId") %></td>
                <td><%= p.get("summonsId") %></td>
                <td>
                  <div style="font-weight:900"><%= p.get("studentName") %></div>
                  <div style="font-size:11px;color:#9ca3af;font-weight:700"><%= p.get("matricNo") %></div>
                </td>
                <td>
                  <% if ("VEHICLE".equals(p.get("summonsType"))) { %>
                    <span class="badge-vehicle">Vehicle</span>
                  <% } else { %>
                    <span class="badge-misconduct">Misconduct</span>
                  <% } %>
                </td>
                <td style="font-weight:950">RM <%= String.format("%.2f", Double.parseDouble(p.get("paymentAmount"))) %></td>
                <td style="color:#6b7280"><%= p.get("paymentDate") %></td>
                <td>
                  <% if ("PENDING_OFFICE".equals(payStatus)) { %>
                    <span class="badge-pending">Pending</span>
                  <% } else { %>
                    <span class="badge-paid">Verified</span>
                  <% } %>
                </td>
                <td>
                  <% if ("PENDING_OFFICE".equals(payStatus)) { %>
                    <a href="<%=request.getContextPath()%>/clerical/payments/review?id=<%= p.get("paymentId") %>"
                       class="btn-review">Review</a>
                  <% } else { %>
                    <span style="font-size:12px;color:#9ca3af;font-weight:700">Done</span>
                  <% } %>
                </td>
              </tr>
              <%
                  }
                }
              %>
              <% if (!hasRows) { %>
              <tr>
                <td colspan="8">
                  <div class="empty-state">
                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none">
                      <rect width="20" height="14" x="2" y="5" rx="2" stroke="#d1d5db" stroke-width="2"/>
                      <path d="M2 10h20" stroke="#d1d5db" stroke-width="2"/>
                    </svg>
                    <p>No office payments found.</p>
                  </div>
                </td>
              </tr>
              <% } %>
            </tbody>
          </table>
        </div>
      </div>

    </div></main>
</div>

<script>
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