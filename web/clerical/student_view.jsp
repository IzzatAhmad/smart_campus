<%-- 
    Document   : student_view.jsp (Clerical - Single Student Detail)
    Author     : SHAHRUL
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.ClericalStaff"%>
<%@page import="java.util.*"%>
<%
    ClericalStaff c = (ClericalStaff) session.getAttribute("clerical");
    if (c == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    Map<String, Object> info        = (Map<String, Object>) request.getAttribute("studentInfo");
    List<Map<String, Object>> summonsList = (List<Map<String, Object>>) request.getAttribute("summonsList");
    List<Map<String, Object>> vehicleList = (List<Map<String, Object>>) request.getAttribute("vehicleList");

    if (info == null || info.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/clerical/students/list");
        return;
    }

    String name        = (String) info.get("studentName");
    String studentId   = (String) info.get("studentId");
    String matricNo    = (String) info.get("matricNo");
    String email       = (String) info.get("email");
    String phone       = (String) info.get("phoneNumber");
    String faculty     = (String) info.get("faculty");
    int    total       = info.get("totalSummons") != null ? (int) info.get("totalSummons") : 0;
    int    unpaid      = info.get("unpaid")       != null ? (int) info.get("unpaid")       : 0;
    int    paid        = info.get("paid")         != null ? (int) info.get("paid")         : 0;
    int    appealed    = info.get("appealed")     != null ? (int) info.get("appealed")     : 0;
    double outstanding = info.get("outstanding")  != null ? (double) info.get("outstanding") : 0.0;
    String initial     = name != null && name.length() > 0 ? name.substring(0,1).toUpperCase() : "?";

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
  <title><%= name %> | Student Detail</title>
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
    .main{flex:1;min-width:0;margin-left:260px;display:flex;flex-direction:column}
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
      .main{margin-left:0}
      .sidebar{transform:translateX(-100%)}
      .sidebar.show{transform:translateX(0)}
      .info-grid{grid-template-columns:1fr 1fr}
      .stats-row{grid-template-columns:1fr 1fr}
      .usertext{display:block}
    }

    /* ── Content ── */
    .content{padding:24px 20px;max-width:1000px}

    /* ── Profile Card ── */
    .profile-card{background:#fff;border:1px solid #e5e7eb;border-radius:22px;padding:24px;box-shadow:0 4px 12px rgba(17,24,39,.04);margin-bottom:20px}
    .profile-header{display:flex;gap:20px;align-items:center;margin-bottom:20px}
    .profile-avatar{width:64px;height:64px;border-radius:999px;background:#ede9fe;color:#6f3cff;display:flex;align-items:center;justify-content:center;font-weight:950;font-size:24px;flex-shrink:0}
    .profile-name{font-size:20px;font-weight:950;color:#111827}
    .profile-meta{font-size:13px;color:#6b7280;font-weight:600;margin-top:4px}
    .info-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:14px}
    .info-item{background:#f9fafb;border-radius:14px;padding:14px 16px}
    .info-label{font-size:11px;font-weight:900;color:#9ca3af;text-transform:uppercase;letter-spacing:.08em;margin-bottom:4px}
    .info-value{font-size:14px;font-weight:950;color:#111827}

    /* ── Stats Row ── */
    .stats-row{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:20px}
    .stat-card{background:#fff;border:1px solid #e5e7eb;border-radius:18px;padding:16px;text-align:center;box-shadow:0 4px 12px rgba(17,24,39,.04)}
    .stat-value{font-size:26px;font-weight:950;color:#111827}
    .stat-label{font-size:11px;font-weight:900;color:#6b7280;text-transform:uppercase;letter-spacing:.10em;margin-top:4px}
    .stat-unpaid .stat-value{color:#ea580c}
    .stat-paid .stat-value{color:#16a34a}
    .stat-appealed .stat-value{color:#2563eb}
    .stat-total .stat-value{color:#6f3cff}

    /* ── Vehicle Row ── */
    .section-title{font-size:16px;font-weight:950;color:#111827;margin-bottom:14px}
    .vehicle-row{display:flex;gap:12px;align-items:center;padding:12px 16px;background:#f9fafb;border-radius:14px;margin-bottom:8px}
    .vehicle-icon{width:38px;height:38px;border-radius:12px;background:#eff6ff;color:#2563eb;display:flex;align-items:center;justify-content:center;flex-shrink:0}
    .vehicle-plate{font-weight:950;color:#111827;font-size:13px}
    .vehicle-meta{font-size:12px;color:#6b7280;font-weight:600;margin-top:2px}
    .pill-approved{font-size:10px;font-weight:950;padding:4px 10px;border-radius:999px;background:#f0fdf4;color:#16a34a;border:1px solid #dcfce7}
    .pill-pending{font-size:10px;font-weight:950;padding:4px 10px;border-radius:999px;background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}
    .pill-rejected{font-size:10px;font-weight:950;padding:4px 10px;border-radius:999px;background:#fef2f2;color:#dc2626;border:1px solid #fee2e2}

    /* ── Table Card Header ── */
    .table-card-header{padding:16px 20px;border-bottom:1px solid #f1f5f9;font-size:16px;font-weight:950;color:#111827}
    .empty-mini{text-align:center;padding:24px;color:#9ca3af;font-weight:700;font-size:13px}
  </style>
</head>
<body>
<div id="overlay" class="overlay" onclick="closeSidebar()"></div>
<div class="app">

  <!-- SIDEBAR -->
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
      <a class="active" href="<%=request.getContextPath()%>/clerical/students/list">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2" stroke="currentColor" stroke-width="2"/><circle cx="9" cy="7" r="4" stroke="currentColor" stroke-width="2"/><path d="M23 21v-2a4 4 0 00-3-3.87" stroke="currentColor" stroke-width="2"/><path d="M16 3.13a4 4 0 010 7.75" stroke="currentColor" stroke-width="2"/></svg>
        Student Activity
      </a>
      <a href="<%=request.getContextPath()%>/clerical/patrol/list">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" stroke="currentColor" stroke-width="2"/></svg>
        Patrol Activity Log
      </a>
      <a href="<%=request.getContextPath()%>/clerical/payments/monitor">
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

  <!-- MAIN -->
  <main class="main">
    <header class="header">
      <button class="hamburger d-lg-none" onclick="openSidebar()">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none"><path d="M4 6h16M4 12h16M4 18h16" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
      </button>
      <div class="portal-title">CLERICAL Portal</div>
      <div class="userbox">
        <div class="avatar"><%= c.getClericalName().substring(0,1).toUpperCase() %></div>
      </div>
    </header>

    <div class="content">

      <a href="<%=request.getContextPath()%>/clerical/students/list" class="btn-back">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M15 18l-6-6 6-6" stroke="currentColor" stroke-width="2"/></svg>
        Back to Students
      </a>

      <!-- Profile Card -->
      <div class="profile-card">
        <div class="profile-header">
          <div class="profile-avatar"><%= initial %></div>
          <div>
            <div class="profile-name"><%= name %></div>
            <div class="profile-meta"><%= matricNo %> • <%= faculty %></div>
            <div class="profile-meta"><%= studentId %></div>
          </div>
        </div>
        <div class="info-grid">
          <div class="info-item">
            <div class="info-label">Email</div>
            <div class="info-value" style="font-size:13px"><%= email %></div>
          </div>
          <div class="info-item">
            <div class="info-label">Phone</div>
            <div class="info-value"><%= phone %></div>
          </div>
          <div class="info-item">
            <div class="info-label">Faculty</div>
            <div class="info-value"><%= faculty %></div>
          </div>
        </div>
      </div>

      <!-- Stats Row -->
      <div class="stats-row">
        <div class="stat-card stat-total">
          <div class="stat-value"><%= total %></div>
          <div class="stat-label">Total Summons</div>
        </div>
        <div class="stat-card stat-unpaid">
          <div class="stat-value"><%= unpaid %></div>
          <div class="stat-label">Unpaid</div>
        </div>
        <div class="stat-card stat-paid">
          <div class="stat-value"><%= paid %></div>
          <div class="stat-label">Paid</div>
        </div>
        <div class="stat-card stat-appealed">
          <div class="stat-value" style="font-size:20px">RM <%= String.format("%.2f", outstanding) %></div>
          <div class="stat-label">Outstanding</div>
        </div>
      </div>

      <!-- Registered Vehicles -->
      <div class="table-card">
        <div class="table-card-header">🚗 Registered Vehicles (<%= vehicleList != null ? vehicleList.size() : 0 %>)</div>
        <div style="padding:16px">
          <% if (vehicleList != null && !vehicleList.isEmpty()) {
               for (Map<String, Object> v : vehicleList) {
                 String vStatus = (String) v.get("status");
                 String vPill   = "APPROVED".equals(vStatus) ? "pill-approved" : "REJECTED".equals(vStatus) ? "pill-rejected" : "pill-pending";
          %>
          <div class="vehicle-row">
            <div class="vehicle-icon">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M5 17H3v-5l2-5h14l2 5v5h-2" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><circle cx="7" cy="17" r="2" stroke="currentColor" stroke-width="2"/><circle cx="17" cy="17" r="2" stroke="currentColor" stroke-width="2"/></svg>
            </div>
            <div style="flex:1">
              <div class="vehicle-plate"><%= v.get("plateNumber") %></div>
              <div class="vehicle-meta"><%= v.get("vehicleType") %> • <%= v.get("brand") %> • <%= v.get("color") %> • <%= v.get("engineCc") %>cc</div>
            </div>
            <span class="<%= vPill %>"><%= vStatus %></span>
          </div>
          <% } } else { %>
          <div class="empty-mini">No vehicles registered.</div>
          <% } %>
        </div>
      </div>

      <!-- Summons Table -->
      <div class="table-card">
        <div class="table-card-header">📋 Summons History (<%= summonsList != null ? summonsList.size() : 0 %>)</div>
        <div style="overflow-x:auto">
          <table>
            <thead>
              <tr>
                <th>Summons ID</th>
                <th>Offense</th>
                <th>Type</th>
                <th>Identifier</th>
                <th>Location</th>
                <th>Amount</th>
                <th>Date</th>
                <th>Reported By</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <% if (summonsList != null && !summonsList.isEmpty()) {
                   for (Map<String, Object> sm : summonsList) {
                     String smStatus = (String) sm.get("status");
                     String smPill = "PAID".equals(smStatus) ? "pill-paid" : "APPEALED".equals(smStatus) ? "pill-appealed" : "pill-unpaid";
                     String smType = (String) sm.get("summonsType");
                     String identifier = sm.get("plateNumber") != null ? (String)sm.get("plateNumber") : (String)sm.get("matricNo");
              %>
              <tr>
                <td style="font-weight:950;color:#111827;font-size:13px"><%= sm.get("summonsId") %></td>
                <td style="font-size:13px;font-weight:700;color:#374151"><%= sm.get("offenseName") %></td>
                <td><span class="type-pill <%= "VEHICLE".equals(smType) ? "type-vehicle" : "type-misconduct" %>"><%= smType %></span></td>
                <td style="font-size:13px;font-weight:700;color:#374151"><%= identifier != null ? identifier : "-" %></td>
                <td style="font-size:12px;color:#6b7280;font-weight:600"><%= sm.get("location") %></td>
                <td style="font-weight:950;color:#111827">RM <%= String.format("%.2f", (double)sm.get("amount")) %></td>
                <td style="font-size:12px;color:#6b7280;font-weight:700"><%= sm.get("summonsDate") %></td>
                <td style="font-size:12px;color:#6b7280;font-weight:700"><%= sm.get("patrolName") %></td>
                <td><span class="status-pill <%= smPill %>"><%= smStatus %></span></td>
              </tr>
              <% } } else { %>
              <tr><td colspan="9"><div class="empty-mini">No summons found for this student.</div></td></tr>
              <% } %>
            </tbody>
          </table>
        </div>
      </div>

    </div>
  </main>
</div>

<script>
  function openSidebar(){document.getElementById("sidebar").classList.add("show");document.getElementById("overlay").classList.add("show");}
  function closeSidebar(){document.getElementById("sidebar").classList.remove("show");document.getElementById("overlay").classList.remove("show");}
</script>
</body>
</html>
