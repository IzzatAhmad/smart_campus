<%-- dashboard.jsp (Clerical) --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.ClericalStaff"%>
<%@page import="model.Appeal"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%
    ClericalStaff c = (ClericalStaff) session.getAttribute("clerical");
    if (c == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    int    totalStudents    = request.getAttribute("totalStudents")    != null ? (int)    request.getAttribute("totalStudents")    : 0;
    int    totalPatrol      = request.getAttribute("totalPatrol")      != null ? (int)    request.getAttribute("totalPatrol")      : 0;
    int    totalSummons     = request.getAttribute("totalSummons")     != null ? (int)    request.getAttribute("totalSummons")     : 0;
    int    unpaidSummons    = request.getAttribute("unpaidSummons")    != null ? (int)    request.getAttribute("unpaidSummons")    : 0;
    double totalOutstanding = request.getAttribute("totalOutstanding") != null ? (double) request.getAttribute("totalOutstanding") : 0.0;
    int    pendingPayments  = request.getAttribute("pendingPayments")  != null ? (int)    request.getAttribute("pendingPayments")  : 0;
    int    pendingVehicles  = request.getAttribute("pendingVehicles")  != null ? (int)    request.getAttribute("pendingVehicles")  : 0;
    int    pendingAppeals   = request.getAttribute("pendingAppeals")   != null ? (int)    request.getAttribute("pendingAppeals")   : 0;

    @SuppressWarnings("unchecked")
    List<Appeal> pendingAppealList = (List<Appeal>) request.getAttribute("pendingAppealList");
    @SuppressWarnings("unchecked")
    List<Map<String, String>> pendingOfficeList = (List<Map<String, String>>) request.getAttribute("pendingOfficeList");

    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg   = (String) session.getAttribute("errorMsg");
    session.removeAttribute("successMsg");
    session.removeAttribute("errorMsg");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Clerical Dashboard | Smart Campus</title>
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
    .bell{
      width:40px;height:40px;border-radius:12px;border:0;background:transparent;
      display:flex;align-items:center;justify-content:center;color:#9ca3af;position:relative;
    }
    .bell:hover{background:#f3f4f6;color:#6f3cff}
    .dot{width:8px;height:8px;border-radius:999px;background:#ef4444;position:absolute;top:10px;right:10px}
    .userbox{display:flex;align-items:center;gap:12px;border-left:1px solid #f1f5f9;padding-left:14px}
    .usertext{display:none}
    .avatar{width:40px;height:40px;border-radius:999px;background:#ede9fe;color:#6f3cff;display:flex;align-items:center;justify-content:center;font-weight:900}

    .content{padding:18px 16px 26px}

    /* ── Shared Alerts ── */
    .alert-success{background:#f0fdf4;border:1px solid #bbf7d0;color:#15803d;border-radius:14px;padding:12px 16px;font-weight:700;margin-bottom:16px}
    .alert-error{background:#fef2f2;border:1px solid #fecaca;color:#dc2626;border-radius:14px;padding:12px 16px;font-weight:700;margin-bottom:16px}

    /* ── Welcome Banner ── */
    .welcome{
      background:linear-gradient(135deg,#6f3cff,#4338ca);
      border-radius:26px;padding:26px 30px;color:#fff;
      position:relative;overflow:hidden;margin-bottom:20px;
    }
    .welcome h2{margin:0 0 6px;font-weight:950;font-size:22px}
    .welcome p{margin:0 0 18px;color:#e9d5ff;font-weight:600;font-size:14px}
    .welcome-icon{position:absolute;right:-20px;top:10px;opacity:.12}
    .welcome-actions{display:flex;gap:10px;flex-wrap:wrap}
    .welcome-btn{
      display:inline-flex;align-items:center;gap:8px;
      background:#fff;color:#6f3cff;font-weight:900;
      padding:9px 16px;border-radius:14px;border:0;
      text-decoration:none;cursor:pointer;font-size:13px;
    }
    .welcome-btn:hover{background:#faf5ff;color:#6f3cff}
    .welcome-btn.orange{background:rgba(255,255,255,.15);color:#fff;border:1.5px solid rgba(255,255,255,.3)}
    .welcome-btn.orange:hover{background:rgba(255,255,255,.25);color:#fff}

    /* ── Stats Row ── */
    .stats-row{
      display:grid;grid-template-columns:repeat(6,1fr);
      gap:12px;margin-bottom:20px;
    }
    .stat-card{
      background:#fff;border:1px solid #e5e7eb;border-radius:20px;
      padding:16px;box-shadow:0 4px 12px rgba(17,24,39,.04);
      text-align:center;
    }
    .stat-icon{
      width:40px;height:40px;border-radius:12px;
      display:flex;align-items:center;justify-content:center;
      margin:0 auto 10px;
    }
    .ico-student{background:#eff6ff;color:#2563eb}
    .ico-patrol{background:#f3e8ff;color:#7c3aed}
    .ico-summons{background:#fff7ed;color:#ea580c}
    .ico-unpaid{background:#fef2f2;color:#dc2626}
    .ico-payment{background:#f0fdf4;color:#16a34a}
    .ico-vehicle{background:#fdf4ff;color:#9333ea}
    .stat-value{font-size:22px;font-weight:950;color:#111827}
    .stat-label{font-size:10px;font-weight:900;color:#6b7280;text-transform:uppercase;letter-spacing:.10em;margin-top:3px}
    .stat-card.urgent .stat-value{color:#dc2626}
    .stat-card.warn .stat-value{color:#ea580c}

    /* ── Grid Bottom ── */
    .grid-bottom{display:grid;grid-template-columns:1fr 1fr;gap:16px}

    /* ── Section Card ── */
    .section-card{background:#fff;border:1px solid #e5e7eb;border-radius:22px;box-shadow:0 4px 12px rgba(17,24,39,.04);overflow:hidden}
    .section-head{
      display:flex;align-items:center;justify-content:space-between;
      padding:16px 20px;border-bottom:1px solid #f1f5f9;
    }
    .section-head h3{margin:0;font-size:16px;font-weight:950;color:#111827}
    .view-all{font-weight:900;color:#6f3cff;text-decoration:none;font-size:13px}
    .view-all:hover{color:#5b21b6}

    /* ── Shared Pills ── */
    .status-pill{font-size:10px;font-weight:950;text-transform:uppercase;letter-spacing:.08em;padding:5px 10px;border-radius:999px;display:inline-block}
    .pill-pending{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}
    .pill-paid{background:#f0fdf4;color:#16a34a;border:1px solid #dcfce7}
    .pill-unpaid{background:#fef2f2;color:#dc2626;border:1px solid #fee2e2}
    .pill-vehicle{background:#eff6ff;color:#2563eb;border:1px solid #dbeafe}
    .pill-misconduct{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}

    /* ── Table ── */
    .mini-table{width:100%;border-collapse:collapse}
    .mini-table th{font-size:10px;text-transform:uppercase;letter-spacing:.12em;color:#9ca3af;font-weight:900;padding:10px 16px;border-bottom:1px solid #f1f5f9;background:#fafafa;white-space:nowrap}
    .mini-table td{padding:12px 16px;border-bottom:1px solid #f9fafb;vertical-align:middle;font-size:13px;font-weight:700;color:#111827}
    .mini-table tr:last-child td{border-bottom:0}
    .mini-table tr:hover td{background:#fafafa}
    .td-id{font-weight:950;color:#111827;font-size:12px}
    .td-sub{font-size:11px;color:#9ca3af;font-weight:600;margin-top:2px}

    /* ── Action Button ── */
    .btn-action{
      border:0;background:#f3e8ff;color:#6f3cff;font-weight:950;
      padding:6px 12px;border-radius:10px;font-size:11px;
      text-decoration:none;display:inline-block;white-space:nowrap;
    }
    .btn-action:hover{background:#ede9fe;color:#6f3cff}
    .btn-action.green{background:#f0fdf4;color:#16a34a}
    .btn-action.green:hover{background:#dcfce7;color:#16a34a}

    /* ── Empty mini ── */
    .empty-mini{text-align:center;padding:28px 16px;color:#9ca3af;font-weight:700;font-size:13px}

    /* ── Responsive ── */
    @media(max-width:1200px){.stats-row{grid-template-columns:repeat(3,1fr)}}
    @media(max-width:992px){
      .main{margin-left:0;width:100%}
      .sidebar{transform:translateX(-100%)}
      .sidebar.show{transform:translateX(0)}
      .stats-row{grid-template-columns:repeat(2,1fr)}
      .grid-bottom{grid-template-columns:1fr}
      .usertext{display:block}
    }
    @media(max-width:576px){.stats-row{grid-template-columns:1fr 1fr}}
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
      <a class="active" href="<%=request.getContextPath()%>/clerical/dashboard">
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
        <% if (pendingAppeals > 0 || pendingPayments > 0) { %>
        <button class="bell" type="button" title="Pending actions require your attention">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
            <path d="M18 8a6 6 0 10-12 0c0 7-3 7-3 7h18s-3 0-3-7" stroke="currentColor" stroke-width="2" stroke-linejoin="round"/>
            <path d="M13.73 21a2 2 0 01-3.46 0" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>
          <span class="dot"></span>
        </button>
        <% } %>
        <div class="userbox">
          <div class="usertext">
            <div style="font-weight:900;color:#111827;font-size:14px"><%= c.getClericalName() %></div>
            <div style="font-size:11px;color:#6b7280;font-weight:900;letter-spacing:.10em;text-transform:uppercase"><%= c.getClericalStaffId() %></div>
          </div>
          <div class="avatar"><%= c.getClericalName().substring(0,1).toUpperCase() %></div>
        </div>
      </div>
    </header>

    <div class="content">

      <% if (successMsg != null) { %><div class="alert-success">✓ <%= successMsg %></div><% } %>
      <% if (errorMsg != null) { %><div class="alert-error">✕ <%= errorMsg %></div><% } %>

      <!-- ── Welcome Banner ── -->
      <div class="welcome">
        <h2>Hello, <%= c.getClericalName() %>!</h2>
        <% if (pendingAppeals > 0 || pendingPayments > 0 || pendingVehicles > 0) { %>
        <p>
          You have
          <% if (pendingAppeals > 0) { %><b><%= pendingAppeals %> appeal<%= pendingAppeals>1?"s":"" %></b> pending review<% } %>
          <% if (pendingAppeals > 0 && (pendingPayments > 0 || pendingVehicles > 0)) { %>, <% } %>
          <% if (pendingPayments > 0) { %><b><%= pendingPayments %> office payment<%= pendingPayments>1?"s":"" %></b> awaiting verification<% } %>
          <% if (pendingPayments > 0 && pendingVehicles > 0) { %>, <% } %>
          <% if (pendingVehicles > 0) { %><b><%= pendingVehicles %> vehicle request<%= pendingVehicles>1?"s":"" %></b> pending approval<% } %>
          — please action them promptly.
        </p>
        <% } else { %>
        <p>Everything is up to date. No pending actions at this time.</p>
        <% } %>
        <div class="welcome-actions">
          <% if (pendingAppeals > 0) { %>
          <a href="<%=request.getContextPath()%>/clerical/appeals/list" class="welcome-btn">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z" stroke="currentColor" stroke-width="2" stroke-linejoin="round"/></svg>
            Review Appeals (<%= pendingAppeals %>)
          </a>
          <% } %>
          <% if (pendingPayments > 0) { %>
          <a href="<%=request.getContextPath()%>/clerical/payments/monitor" class="welcome-btn">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><rect width="20" height="14" x="2" y="5" rx="2" stroke="currentColor" stroke-width="2"/><path d="M2 10h20" stroke="currentColor" stroke-width="2"/></svg>
            Verify Payments (<%= pendingPayments %>)
          </a>
          <% } %>
          <% if (pendingVehicles > 0) { %>
          <a href="<%=request.getContextPath()%>/clerical/vehicle/requests" class="welcome-btn orange">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M5 17H3v-5l2-5h14l2 5v5h-2" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><circle cx="7" cy="17" r="2" stroke="currentColor" stroke-width="2"/><circle cx="17" cy="17" r="2" stroke="currentColor" stroke-width="2"/></svg>
            Approve Vehicles (<%= pendingVehicles %>)
          </a>
          <% } %>
          <a href="<%=request.getContextPath()%>/clerical/report/view" class="welcome-btn orange">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M18 20V10M12 20V4M6 20v-6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
            Analytics & Reports
          </a>
        </div>
        <div class="welcome-icon">
          <svg width="160" height="160" viewBox="0 0 24 24" fill="none">
            <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z" stroke="currentColor" stroke-width="2"/>
            <path d="M14 2v6h6" stroke="currentColor" stroke-width="2"/>
          </svg>
        </div>
      </div>

      <!-- ── Stats Row (6 cards) ── -->
      <div class="stats-row">

        <!-- Total Students -->
        <div class="stat-card">
          <div class="stat-icon ico-student">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2" stroke="currentColor" stroke-width="2"/><circle cx="9" cy="7" r="4" stroke="currentColor" stroke-width="2"/><path d="M23 21v-2a4 4 0 00-3-3.87" stroke="currentColor" stroke-width="2"/><path d="M16 3.13a4 4 0 010 7.75" stroke="currentColor" stroke-width="2"/></svg>
          </div>
          <div class="stat-value"><%= totalStudents %></div>
          <div class="stat-label">Students</div>
        </div>

        <!-- Total Patrol -->
        <div class="stat-card">
          <div class="stat-icon ico-patrol">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" stroke="currentColor" stroke-width="2"/></svg>
          </div>
          <div class="stat-value"><%= totalPatrol %></div>
          <div class="stat-label">Patrol Staff</div>
        </div>

        <!-- Total Summons -->
        <div class="stat-card">
          <div class="stat-icon ico-summons">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z" stroke="currentColor" stroke-width="2"/><path d="M14 2v6h6" stroke="currentColor" stroke-width="2"/></svg>
          </div>
          <div class="stat-value"><%= totalSummons %></div>
          <div class="stat-label">Total Summons</div>
        </div>

        <!-- Unpaid Summons -->
        <div class="stat-card warn">
          <div class="stat-icon ico-unpaid">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M12 9v4m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
          </div>
          <div class="stat-value"><%= unpaidSummons %></div>
          <div class="stat-label">Unpaid Summons</div>
        </div>

        <!-- Pending Payments -->
        <div class="stat-card <%= pendingPayments > 0 ? "urgent" : "" %>">
          <div class="stat-icon ico-payment">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><rect width="20" height="14" x="2" y="5" rx="2" stroke="currentColor" stroke-width="2"/><path d="M2 10h20" stroke="currentColor" stroke-width="2"/></svg>
          </div>
          <div class="stat-value"><%= pendingPayments %></div>
          <div class="stat-label">Pending Payments</div>
        </div>

        <!-- Pending Vehicles -->
        <div class="stat-card <%= pendingVehicles > 0 ? "urgent" : "" %>">
          <div class="stat-icon ico-vehicle">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M5 17H3v-5l2-5h14l2 5v5h-2" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><circle cx="7" cy="17" r="2" stroke="currentColor" stroke-width="2"/><circle cx="17" cy="17" r="2" stroke="currentColor" stroke-width="2"/></svg>
          </div>
          <div class="stat-value"><%= pendingVehicles %></div>
          <div class="stat-label">Vehicle Requests</div>
        </div>

      </div>

      <!-- ── Grid Bottom ── -->
      <div class="grid-bottom">

        <!-- Pending Appeals -->
        <div class="section-card">
          <div class="section-head">
            <h3>
              Pending Appeals
              <% if (pendingAppeals > 0) { %>
              <span style="margin-left:8px;background:#fef2f2;color:#dc2626;font-size:11px;font-weight:950;padding:3px 9px;border-radius:999px;border:1px solid #fecaca"><%= pendingAppeals %></span>
              <% } %>
            </h3>
            <a href="<%=request.getContextPath()%>/clerical/appeals/list" class="view-all">View All</a>
          </div>

          <% if (pendingAppealList != null && !pendingAppealList.isEmpty()) { %>
          <table class="mini-table">
            <thead>
              <tr>
                <th>Appeal</th>
                <th>Student</th>
                <th>Offense</th>
                <th>Amount</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <% for (Appeal a : pendingAppealList) { %>
              <tr>
                <td>
                  <div class="td-id"><%= a.getAppealId() %></div>
                  <div class="td-sub"><%= a.getSummonsId() %></div>
                </td>
                <td style="color:#374151"><%= a.getStudentName() != null ? a.getStudentName() : a.getStudentId() %></td>
                <td style="max-width:110px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:#6b7280">
                  <%= a.getOffenseName() != null ? a.getOffenseName() : a.getSummonsType() %>
                </td>
                <td style="font-weight:950;color:#ea580c">RM <%= String.format("%.2f", a.getAmount()) %></td>
                <td>
                  <a href="<%=request.getContextPath()%>/clerical/appeals/review?id=<%= a.getAppealId() %>" class="btn-action">Review</a>
                </td>
              </tr>
              <% } %>
            </tbody>
          </table>
          <% } else { %>
          <div class="empty-mini">✓ No pending appeals. All caught up!</div>
          <% } %>
        </div>

        <!-- Pending Office Payments -->
        <div class="section-card">
          <div class="section-head">
            <h3>
              Pending Office Payments
              <% if (pendingPayments > 0) { %>
              <span style="margin-left:8px;background:#fef2f2;color:#dc2626;font-size:11px;font-weight:950;padding:3px 9px;border-radius:999px;border:1px solid #fecaca"><%= pendingPayments %></span>
              <% } %>
            </h3>
            <a href="<%=request.getContextPath()%>/clerical/payments/monitor" class="view-all">View All</a>
          </div>

          <% if (pendingOfficeList != null && !pendingOfficeList.isEmpty()) { %>
          <table class="mini-table">
            <thead>
              <tr>
                <th>Payment</th>
                <th>Student</th>
                <th>Type</th>
                <th>Amount</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <% for (Map<String, String> pm : pendingOfficeList) { %>
              <tr>
                <td>
                  <div class="td-id"><%= pm.get("paymentId") %></div>
                  <div class="td-sub"><%= pm.get("summonsId") %></div>
                </td>
                <td style="color:#374151"><%= pm.get("studentName") != null ? pm.get("studentName") : "—" %></td>
                <td>
                  <span class="status-pill <%= "VEHICLE".equals(pm.get("summonsType")) ? "pill-vehicle" : "pill-misconduct" %>">
                    <%= pm.get("summonsType") %>
                  </span>
                </td>
                <td style="font-weight:950;color:#16a34a">RM <%= String.format("%.2f", Double.parseDouble(pm.get("paymentAmount"))) %></td>
                <td>
                  <a href="<%=request.getContextPath()%>/clerical/payments/review?id=<%= pm.get("paymentId") %>" class="btn-action green">Verify</a>
                </td>
              </tr>
              <% } %>
            </tbody>
          </table>
          <% } else { %>
          <div class="empty-mini">✓ No office payments pending verification.</div>
          <% } %>
        </div>

      </div><!-- end grid-bottom -->

    </div><!-- end content -->
  </main>
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
