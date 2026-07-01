<%-- 
    Document   : offense_list
    Created on : 9 Apr 2026, 2:22:19 pm
    Author     : SHAHRUL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.ClericalStaff"%>
<%@page import="model.OffenseType"%>
<%@page import="java.util.List"%>
<%
  ClericalStaff c = (ClericalStaff) session.getAttribute("clerical");
  if (c == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
  }

  String currentPage = request.getRequestURI();

  // Success/Error message from servlet
  String successMsg = (String) session.getAttribute("successMsg");
  String errorMsg = (String) session.getAttribute("errorMsg");
  session.removeAttribute("successMsg");
  session.removeAttribute("errorMsg");

  // List of offense types from servlet
  List<OffenseType> offenseList = (List<OffenseType>) request.getAttribute("offenseList");

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
  <title>Manage Offense Type | Smart Campus</title>
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
      .stats-row{grid-template-columns:repeat(2,1fr)}
      .usertext{display:block}
    }

    /* ── Stats Row ── */
    .stats-row{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:20px}
    .stat-card{background:#fff;border:1px solid #e5e7eb;border-radius:20px;padding:18px 20px;box-shadow:0 4px 12px rgba(17,24,39,.04)}
    .stat-label{font-size:11px;font-weight:900;color:#6b7280;text-transform:uppercase;letter-spacing:.10em;margin-bottom:6px}
    .stat-value{font-size:26px;font-weight:950;color:#111827}
    .stat-sub{font-size:11px;font-weight:700;color:#9ca3af;margin-top:2px}

    /* ── Offense Pills ── */
    .category-pill{font-size:10px;font-weight:950;text-transform:uppercase;letter-spacing:.08em;padding:5px 10px;border-radius:999px;display:inline-block}
    .cat-misconduct{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}
    .cat-vehicle{background:#eff6ff;color:#2563eb;border:1px solid #dbeafe}
    .status-active{background:#f0fdf4;color:#16a34a;border:1px solid #dcfce7}
    .status-inactive{background:#f9fafb;color:#9ca3af;border:1px solid #e5e7eb}
    .amount-text{font-weight:950;color:#111827;font-size:15px}
    .offense-name{font-weight:950;color:#111827;font-size:14px}
    .offense-id{font-size:11px;color:#9ca3af;font-weight:700}
    .offense-desc{font-size:12px;color:#6b7280;font-weight:600;margin-top:2px}

    /* ── Action Buttons ── */
    .action-btn{border:0;padding:7px 12px;border-radius:10px;font-weight:900;font-size:12px;cursor:pointer;transition:.15s}
    .btn-edit{background:#f3e8ff;color:#6f3cff}
    .btn-edit:hover{background:#ede9fe}
    .btn-deactivate{background:#fff7ed;color:#ea580c}
    .btn-deactivate:hover{background:#ffedd5}
    .btn-activate{background:#f0fdf4;color:#16a34a}
    .btn-activate:hover{background:#dcfce7}

    /* ── Add Button ── */
    .btn-add{background:#6f3cff;color:#fff;border:0;padding:12px 20px;border-radius:14px;font-weight:900;display:flex;align-items:center;gap:8px;cursor:pointer}
    .btn-add:hover{background:#5b21b6}

    /* ── Modal ── */
    .modal-overlay{position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:100;display:none;align-items:center;justify-content:center}
    .modal-overlay.show{display:flex}
    .modal-box{background:#fff;border-radius:24px;padding:32px;width:100%;max-width:480px;box-shadow:0 25px 50px rgba(0,0,0,.15)}
    .modal-title{font-size:20px;font-weight:950;color:#111827;margin-bottom:6px}
    .modal-sub{font-size:13px;color:#6b7280;font-weight:700;margin-bottom:24px}
    .form-label{font-size:12px;font-weight:900;color:#374151;text-transform:uppercase;letter-spacing:.08em;margin-bottom:6px;display:block}
    .form-input{width:100%;border:1.5px solid #e5e7eb;border-radius:12px;padding:10px 14px;font-weight:700;color:#111827;background:#f9fafb;font-size:14px;outline:none;box-sizing:border-box}
    .form-input:focus{border-color:#6f3cff;background:#fff}
    .form-group{margin-bottom:16px}
    .modal-actions{display:flex;gap:10px;margin-top:24px;justify-content:flex-end}
    .btn-cancel{border:1.5px solid #e5e7eb;background:#fff;color:#374151;font-weight:900;padding:10px 20px;border-radius:12px;cursor:pointer}
    .btn-cancel:hover{background:#f9fafb}
    .btn-save{border:0;background:#6f3cff;color:#fff;font-weight:900;padding:10px 24px;border-radius:12px;cursor:pointer}
    .btn-save:hover{background:#5b21b6}
    @media(max-width:576px){.stats-row{grid-template-columns:1fr}}
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
      <a class="active" href="<%=request.getContextPath()%>/clerical/offense/list">
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
          <path d="M4 6h16M4 12h16M4 18h16" stroke="currentColor"
                stroke-width="2" stroke-linecap="round"/>
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

      <!-- Alert Messages -->
      <% if (successMsg != null) { %>
        <div class="alert-success">✓ <%= successMsg %></div>
      <% } %>
      <% if (errorMsg != null) { %>
        <div class="alert-error">✕ <%= errorMsg %></div>
      <% } %>

      <!-- Page Header -->
      <div class="page-header">
        <div>
          <h1>Manage Offense Types</h1>
          <p>Add, edit, and manage all misconduct and vehicle offense types and their fines.</p>
        </div>
        <button class="btn-add" onclick="openAddModal()">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
            <path d="M12 5v14M5 12h14" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/>
          </svg>
          Add Offense Type
        </button>
      </div>

      <!-- Stats Row -->
      <div class="stats-row">
        <div class="stat-card">
          <div class="stat-label">Total Offense Types</div>
          <div class="stat-value" id="statTotal">0</div>
          <div class="stat-sub">All categories</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Misconduct</div>
          <div class="stat-value" id="statMisconduct">0</div>
          <div class="stat-sub">Student offenses</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Vehicle</div>
          <div class="stat-value" id="statVehicle">0</div>
          <div class="stat-sub">Vehicle offenses</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Active</div>
          <div class="stat-value" id="statActive">0</div>
          <div class="stat-sub">Currently in use</div>
        </div>
      </div>

      <!-- Filter Bar -->
      <div class="filter-bar">
        <input type="text" id="searchInput" placeholder="Search offense name..."
               oninput="filterTable()" style="flex:1;min-width:200px"/>
        <select id="filterCategory" onchange="filterTable()">
          <option value="">All Categories</option>
          <option value="MISCONDUCT">Misconduct</option>
          <option value="VEHICLE">Vehicle</option>
        </select>
        <select id="filterStatus" onchange="filterTable()">
          <option value="">All Status</option>
          <option value="ACTIVE">Active</option>
          <option value="INACTIVE">Inactive</option>
        </select>
      </div>

      <!-- Table -->
      <div class="table-card">
        <div style="overflow-x:auto">
          <table id="offenseTable">
            <thead>
              <tr>
                <th>Offense</th>
                <th>Category</th>
                <th>Fine Amount</th>
                <th>Status</th>
                <th>Created By</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody id="tableBody">
              <% if (offenseList != null && !offenseList.isEmpty()) {
                   for (OffenseType o : offenseList) { %>
              <tr data-category="<%= o.getOffenseCategory() %>"
                  data-status="<%= o.getStatus() %>">
                <td>
                  <div class="offense-name"><%= o.getOffenseName() %></div>
                  <div class="offense-id"><%= o.getOffenseId() %></div>
                  <% if (o.getDescription() != null && !o.getDescription().isEmpty()) { %>
                  <div class="offense-desc"><%= o.getDescription() %></div>
                  <% } %>
                </td>
                <td>
                  <span class="category-pill <%= o.getOffenseCategory().equals("MISCONDUCT") 
                    ? "cat-misconduct" : "cat-vehicle" %>">
                    <%= o.getOffenseCategory() %>
                  </span>
                </td>
                <td>
                  <span class="amount-text">RM <%= String.format("%.2f", o.getAmount()) %></span>
                </td>
                <td>
                  <span class="status-pill <%= o.getStatus().equals("ACTIVE") 
                    ? "status-active" : "status-inactive" %>">
                    <%= o.getStatus() %>
                  </span>
                </td>
                <td style="font-weight:700;color:#6b7280;font-size:13px">
                  <%= o.getCreatedBy() %>
                </td>
                <td>
                  <div style="display:flex;gap:6px">
                    <button class="action-btn btn-edit"
                      onclick="openEditModal(
                        '<%= o.getOffenseId() %>',
                        '<%= o.getOffenseName() %>',
                        '<%= o.getOffenseCategory() %>',
                        <%= o.getAmount() %>,
                        '<%= o.getDescription() != null ? o.getDescription() : "" %>'
                      )">
                      Edit
                    </button>
                    <% if (o.getStatus().equals("ACTIVE")) { %>
                    <button class="action-btn btn-deactivate"
                      onclick="confirmToggle('<%= o.getOffenseId() %>', 'INACTIVE',
                               '<%= o.getOffenseName() %>')">
                      Deactivate
                    </button>
                    <% } else { %>
                    <button class="action-btn btn-activate"
                      onclick="confirmToggle('<%= o.getOffenseId() %>', 'ACTIVE',
                               '<%= o.getOffenseName() %>')">
                      Activate
                    </button>
                    <% } %>
                  </div>
                </td>
              </tr>
              <%  }
                 } else { %>
              <tr>
                <td colspan="6">
                  <div class="empty-state">
                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none">
                      <path d="M12 9v4m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"
                            stroke="currentColor" stroke-width="2"/>
                    </svg>
                    <p>No offense types found. Click <b>Add Offense Type</b> to get started.</p>
                  </div>
                </td>
              </tr>
              <% } %>
            </tbody>
          </table>
        </div>
      </div>

    </div><!-- end content -->
  </main>
</div><!-- end app -->

<!-- ══════════ ADD MODAL ══════════ -->
<div class="modal-overlay" id="addModal">
  <div class="modal-box">
    <div class="modal-title">Add New Offense Type</div>
    <div class="modal-sub">Fill in the details below to create a new offense type.</div>

    <form action="<%=request.getContextPath()%>/clerical/offense/add" method="post">
      <div class="form-group">
        <label class="form-label">Offense Name *</label>
        <input type="text" name="offenseName" class="form-input"
               placeholder="e.g. Smoking" required/>
      </div>
      <div class="form-group">
        <label class="form-label">Category *</label>
        <select name="offenseCategory" class="form-input" required>
          <option value="">Select category</option>
          <option value="MISCONDUCT">Misconduct (Student)</option>
          <option value="VEHICLE">Vehicle</option>
        </select>
      </div>
      <div class="form-group">
        <label class="form-label">Fine Amount (RM) *</label>
        <input type="number" name="amount" class="form-input"
               placeholder="e.g. 50.00" step="0.01" min="0" required/>
      </div>
      <div class="form-group">
        <label class="form-label">Description (Optional)</label>
        <textarea name="description" class="form-input" rows="3"
                  placeholder="Brief description of this offense..."></textarea>
      </div>
      <input type="hidden" name="createdBy" value="<%= c.getClericalStaffId() %>"/>

      <div class="modal-actions">
        <button type="button" class="btn-cancel" onclick="closeAddModal()">Cancel</button>
        <button type="submit" class="btn-save">Save Offense</button>
      </div>
    </form>
  </div>
</div>

<!-- ══════════ EDIT MODAL ══════════ -->
<div class="modal-overlay" id="editModal">
  <div class="modal-box">
    <div class="modal-title">Edit Offense Type</div>
    <div class="modal-sub">Update the offense details below.</div>

    <form action="<%=request.getContextPath()%>/clerical/offense/edit" method="post">
      <input type="hidden" name="offenseId" id="editOffenseId"/>

      <div class="form-group">
        <label class="form-label">Offense Name *</label>
        <input type="text" name="offenseName" id="editOffenseName"
               class="form-input" required/>
      </div>
      <div class="form-group">
        <label class="form-label">Category *</label>
        <select name="offenseCategory" id="editOffenseCategory" class="form-input" required>
          <option value="MISCONDUCT">Misconduct (Student)</option>
          <option value="VEHICLE">Vehicle</option>
        </select>
      </div>
      <div class="form-group">
        <label class="form-label">Fine Amount (RM) *</label>
        <input type="number" name="amount" id="editAmount"
               class="form-input" step="0.01" min="0" required/>
      </div>
      <div class="form-group">
        <label class="form-label">Description (Optional)</label>
        <textarea name="description" id="editDescription"
                  class="form-input" rows="3"></textarea>
      </div>

      <div class="modal-actions">
        <button type="button" class="btn-cancel" onclick="closeEditModal()">Cancel</button>
        <button type="submit" class="btn-save">Update Offense</button>
      </div>
    </form>
  </div>
</div>

<!-- ══════════ TOGGLE STATUS FORM ══════════ -->
<form id="toggleForm"
      action="<%=request.getContextPath()%>/clerical/offense/toggle"
      method="post" style="display:none">
  <input type="hidden" name="offenseId" id="toggleOffenseId"/>
  <input type="hidden" name="newStatus" id="toggleNewStatus"/>
</form>

<script>
  // ── Sidebar ──
  function openSidebar(){
    document.getElementById("sidebar").classList.add("show");
    document.getElementById("overlay").classList.add("show");
  }
  function closeSidebar(){
    document.getElementById("sidebar").classList.remove("show");
    document.getElementById("overlay").classList.remove("show");
  }

  // ── Add Modal ──
  function openAddModal(){
    document.getElementById("addModal").classList.add("show");
  }
  function closeAddModal(){
    document.getElementById("addModal").classList.remove("show");
  }

  // ── Edit Modal ──
  function openEditModal(id, name, category, amount, desc){
    document.getElementById("editOffenseId").value      = id;
    document.getElementById("editOffenseName").value    = name;
    document.getElementById("editOffenseCategory").value = category;
    document.getElementById("editAmount").value         = amount;
    document.getElementById("editDescription").value    = desc;
    document.getElementById("editModal").classList.add("show");
  }
  function closeEditModal(){
    document.getElementById("editModal").classList.remove("show");
  }

  // ── Toggle Status (Activate / Deactivate) ──
  function confirmToggle(id, newStatus, name){
    let action = newStatus === "INACTIVE" ? "deactivate" : "activate";
    if(confirm("Are you sure you want to " + action + " \"" + name + "\"?")){
      document.getElementById("toggleOffenseId").value = id;
      document.getElementById("toggleNewStatus").value = newStatus;
      document.getElementById("toggleForm").submit();
    }
  }

  // ── Filter Table ──
  function filterTable(){
    let search   = document.getElementById("searchInput").value.toLowerCase();
    let category = document.getElementById("filterCategory").value;
    let status   = document.getElementById("filterStatus").value;
    let rows     = document.querySelectorAll("#tableBody tr[data-category]");

    rows.forEach(row => {
      let name     = row.querySelector(".offense-name").textContent.toLowerCase();
      let rowCat   = row.getAttribute("data-category");
      let rowStat  = row.getAttribute("data-status");

      let matchSearch   = name.includes(search);
      let matchCategory = !category || rowCat === category;
      let matchStatus   = !status   || rowStat === status;

      row.style.display = (matchSearch && matchCategory && matchStatus) ? "" : "none";
    });

    updateStats();
  }

  // ── Update Stats ──
  function updateStats(){
    let rows        = document.querySelectorAll("#tableBody tr[data-category]");
    let visible     = [...rows].filter(r => r.style.display !== "none");
    let misconduct  = visible.filter(r => r.getAttribute("data-category") === "MISCONDUCT").length;
    let vehicle     = visible.filter(r => r.getAttribute("data-category") === "VEHICLE").length;
    let active      = visible.filter(r => r.getAttribute("data-status") === "ACTIVE").length;

    document.getElementById("statTotal").textContent      = visible.length;
    document.getElementById("statMisconduct").textContent = misconduct;
    document.getElementById("statVehicle").textContent    = vehicle;
    document.getElementById("statActive").textContent     = active;
  }

  // ── Close modal when clicking outside ──
  document.getElementById("addModal").addEventListener("click", function(e){
    if(e.target === this) closeAddModal();
  });
  document.getElementById("editModal").addEventListener("click", function(e){
    if(e.target === this) closeEditModal();
  });

  // ── Init stats on load ──
  window.onload = updateStats;
</script>
</body>
</html>
