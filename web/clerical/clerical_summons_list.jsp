<%-- clerical_summons_list.jsp — Clerical: All Summons Records --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.ClericalStaff"%>
<%@page import="model.Summons"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%
    ClericalStaff c = (ClericalStaff) session.getAttribute("clerical");
    if (c == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

    List<Summons> summonsList = (List<Summons>) request.getAttribute("summonsList");
    int totalSummons  = request.getAttribute("totalSummons")  != null ? (int)    request.getAttribute("totalSummons")  : 0;
    int unpaidCount   = request.getAttribute("unpaidCount")   != null ? (int)    request.getAttribute("unpaidCount")   : 0;
    int paidCount     = request.getAttribute("paidCount")     != null ? (int)    request.getAttribute("paidCount")     : 0;
    int appealedCount = request.getAttribute("appealedCount") != null ? (int)    request.getAttribute("appealedCount") : 0;
    int overdueCount  = request.getAttribute("overdueCount")  != null ? (int)    request.getAttribute("overdueCount")  : 0;
    double totalAmt   = request.getAttribute("totalAmt")      != null ? (double) request.getAttribute("totalAmt")      : 0.0;
    double unpaidAmt  = request.getAttribute("unpaidAmt")     != null ? (double) request.getAttribute("unpaidAmt")     : 0.0;
    int selectedYear  = request.getAttribute("selectedYear")  != null ? (int)    request.getAttribute("selectedYear")  : 0;
    int selectedMonth = request.getAttribute("selectedMonth") != null ? (int)    request.getAttribute("selectedMonth") : 0;

    @SuppressWarnings("unchecked")
    List<Integer> availableYears = (List<Integer>) request.getAttribute("availableYears");

    int pendingAppeals = 0; int pendingPayments = 0; int pendingVehicles = 0;
    try {
        pendingAppeals = new dao.AppealDAO().countPendingAppeals();
        try (java.sql.Connection _con = util.DBConnection.getConnection();
             java.sql.PreparedStatement _ps1 = _con.prepareStatement("SELECT COUNT(*) FROM payment WHERE status='PENDING_OFFICE'");
             java.sql.PreparedStatement _ps2 = _con.prepareStatement("SELECT COUNT(*) FROM vehicle WHERE status='PENDING'")) {
            try (java.sql.ResultSet _rs = _ps1.executeQuery()) { if (_rs.next()) pendingPayments = _rs.getInt(1); }
            try (java.sql.ResultSet _rs = _ps2.executeQuery()) { if (_rs.next()) pendingVehicles = _rs.getInt(1); }
        }
    } catch (Exception _ex) {}

    String[] MONTH_NAMES = {"","January","February","March","April","May","June",
                             "July","August","September","October","November","December"};
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>All Summons Records | Smart Campus</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body{margin:0;background:#f5f6fb;font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif}
    .app{min-height:100vh;display:flex}

    /* ── Sidebar ── */
    .sidebar{width:260px;background:#f5f0ff;border-right:1px solid #e4d9f7;position:fixed;inset:0 auto 0 0;z-index:30;transform:translateX(0);transition:transform .25s ease;display:flex;flex-direction:column}
    .brand{display:flex;gap:12px;align-items:center;padding:24px 20px 18px}
    .brand-badge{width:40px;height:40px;border-radius:12px;background:#7c3aed;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:900;font-size:20px;box-shadow:0 8px 24px rgba(124,58,237,.30)}
    .brand-title{font-weight:900;color:#3b1c86;line-height:1.1}
    .brand-sub{font-size:.75rem;color:#7c3aed;font-weight:700}
    .menu{padding:10px 14px;display:flex;flex-direction:column;gap:4px}
    .menu a{text-decoration:none;display:flex;align-items:center;gap:12px;padding:11px 14px;border-radius:12px;color:#5b21b6;font-weight:700;transition:.15s}
    .menu a:hover{background:#ede9fe;color:#4c1d95}
    .menu a.active{background:#7c3aed;color:#fff;box-shadow:0 4px 14px rgba(124,58,237,.25)}
    .menu a.active svg{opacity:1}
    .menu svg{opacity:.75}
    .menu-label{font-size:10px;font-weight:900;letter-spacing:.12em;text-transform:uppercase;color:#a78bfa;padding:10px 14px 4px}
    .notif-badge{margin-left:auto;background:#ef4444;color:#fff;font-size:10px;font-weight:950;padding:2px 8px;border-radius:999px;display:inline-block;flex-shrink:0}
    .sidebar-bottom{margin-top:auto;padding:14px;border-top:1px solid #e4d9f7}
    .logout-btn{width:100%;border:0;background:#f5f0ff;color:#dc2626;font-weight:900;padding:12px 14px;border-radius:12px;text-align:left;cursor:pointer}
    .logout-btn:hover{background:#fef2f2}

    /* ── Overlay ── */
    .overlay{position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:20;display:none}
    .overlay.show{display:block}

    /* ── Main ── */
    .main{flex:1;min-width:0;margin-left:260px;display:flex;flex-direction:column;width:calc(100% - 260px)}
    .header{height:64px;background:#fff;border-bottom:1px solid #e5e7eb;display:flex;align-items:center;justify-content:space-between;padding:0 16px;position:sticky;top:0;z-index:10}
    .hamburger{border:0;background:transparent;padding:8px;border-radius:10px}
    .hamburger:hover{background:#f3f4f6}
    .portal-title{font-weight:800;color:#111827}
    .header-right{display:flex;align-items:center;gap:14px}
    .userbox{display:flex;align-items:center;gap:12px;border-left:1px solid #f1f5f9;padding-left:14px}
    .usertext{display:none}
    .avatar{width:40px;height:40px;border-radius:999px;background:#ede9fe;color:#6f3cff;display:flex;align-items:center;justify-content:center;font-weight:900}
    .content{padding:24px 20px}

    /* ── Page Header ── */
    .page-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:20px}
    .page-header h1{font-size:22px;font-weight:950;color:#111827;margin:0}
    .page-header p{font-size:13px;color:#6b7280;font-weight:700;margin:4px 0 0}

    /* ── Filter Bar ── */
    .filter-bar{
      background:#fff;border:1px solid #e5e7eb;border-radius:18px;
      padding:14px 20px;margin-bottom:20px;
      display:flex;align-items:center;gap:12px;flex-wrap:wrap;
    }
    .filter-bar label{font-size:11px;font-weight:900;color:#374151;text-transform:uppercase;letter-spacing:.08em;white-space:nowrap}
    .filter-select{
      border:1.5px solid #e5e7eb;border-radius:10px;
      padding:8px 12px;font-weight:700;font-size:13px;
      color:#111827;background:#f9fafb;cursor:pointer;outline:none;
    }
    .filter-select:focus{border-color:#7c3aed;background:#fff}
    .btn-filter{
      background:#7c3aed;color:#fff;border:0;
      border-radius:10px;padding:9px 20px;
      font-weight:900;font-size:13px;cursor:pointer;
      display:inline-flex;align-items:center;gap:6px;
    }
    .btn-filter:hover{background:#6d28d9}
    .btn-clear{
      background:#f3f4f6;color:#6b7280;border:0;
      border-radius:10px;padding:9px 16px;
      font-weight:900;font-size:13px;cursor:pointer;
      text-decoration:none;display:inline-flex;align-items:center;gap:6px;
    }
    .btn-clear:hover{background:#e5e7eb;color:#374151}
    .filter-label-active{
      background:#f5f0ff;color:#7c3aed;
      font-size:12px;font-weight:900;
      padding:5px 12px;border-radius:8px;
      border:1.5px solid #e4d9f7;
    }

    /* ── Stats Row ── */
    .stats-row{display:grid;grid-template-columns:repeat(6,1fr);gap:12px;margin-bottom:20px}
    .stat-card{background:#fff;border:1px solid #e5e7eb;border-radius:18px;padding:14px 16px;box-shadow:0 4px 12px rgba(17,24,39,.04);text-align:center}
    .stat-value{font-size:22px;font-weight:950;color:#111827}
    .stat-label{font-size:10px;font-weight:900;color:#6b7280;text-transform:uppercase;letter-spacing:.10em;margin-top:3px}
    .c-total .stat-value{color:#6f3cff}
    .c-unpaid .stat-value{color:#ea580c}
    .c-paid .stat-value{color:#16a34a}
    .c-appealed .stat-value{color:#2563eb}
    .c-overdue .stat-value{color:#dc2626}
    .c-amount .stat-value{font-size:16px;color:#0891b2}

    /* ── Search + Table Filter ── */
    .table-controls{
      background:#fff;border:1px solid #e5e7eb;border-radius:18px;
      padding:14px 18px;margin-bottom:16px;
      display:flex;align-items:center;gap:12px;flex-wrap:wrap;
    }
    .search-input{
      flex:1;min-width:200px;
      border:1.5px solid #e5e7eb;border-radius:10px;
      padding:9px 14px;font-weight:700;color:#374151;
      background:#f9fafb;font-size:13px;outline:none;
    }
    .search-input:focus{border-color:#7c3aed;background:#fff}
    .filter-sel{
      border:1.5px solid #e5e7eb;border-radius:10px;
      padding:9px 12px;font-weight:700;color:#374151;
      background:#f9fafb;font-size:13px;outline:none;
    }
    .filter-sel:focus{border-color:#7c3aed;background:#fff}

    /* ── Table Card ── */
    .table-card{background:#fff;border:1px solid #e5e7eb;border-radius:20px;box-shadow:0 4px 12px rgba(17,24,39,.04);overflow:hidden}
    .table-card table{width:100%;border-collapse:collapse;min-width:800px}
    .table-card thead{background:#f9fafb}
    .table-card th{font-size:11px;text-transform:uppercase;letter-spacing:.12em;color:#6b7280;font-weight:950;padding:13px 16px;border-bottom:1px solid #f1f5f9;white-space:nowrap}
    .table-card td{padding:13px 16px;border-bottom:1px solid #f1f5f9;vertical-align:middle}
    .table-card tr:last-child td{border-bottom:0}
    .table-card tr:hover td{background:#fafafa}

    /* ── Row data ── */
    .summons-id{font-weight:950;color:#111827;font-size:13px}
    .summons-offense{font-size:12px;color:#6b7280;font-weight:600;margin-top:2px}
    .location-text{font-size:12px;color:#6b7280;font-weight:600;max-width:140px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
    .identifier{font-weight:800;color:#374151;font-size:13px}
    .student-name{font-size:12px;color:#6b7280;font-weight:600;margin-top:2px}
    .patrol-name{font-size:12px;color:#6b7280;font-weight:600}

    /* ── Pills ── */
    .status-pill{font-size:10px;font-weight:950;text-transform:uppercase;letter-spacing:.08em;padding:5px 10px;border-radius:999px;display:inline-block}
    .pill-unpaid{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}
    .pill-paid{background:#f0fdf4;color:#16a34a;border:1px solid #dcfce7}
    .pill-appealed{background:#eff6ff;color:#2563eb;border:1px solid #dbeafe}
    .pill-overdue{background:#fef2f2;color:#dc2626;border:1px solid #fee2e2}
    .pill-waived{background:#fdf4ff;color:#9333ea;border:1px solid #f3e8ff}
    .type-pill{font-size:10px;font-weight:950;text-transform:uppercase;padding:5px 10px;border-radius:999px;display:inline-block}
    .type-vehicle{background:#eff6ff;color:#2563eb;border:1px solid #dbeafe}
    .type-misconduct{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}

    /* ── Empty State ── */
    .empty-state{text-align:center;padding:60px 20px;color:#9ca3af}
    .empty-state svg{opacity:.3;margin-bottom:14px;display:block;margin-left:auto;margin-right:auto}
    .empty-state p{font-weight:700;font-size:15px;margin:0}

    /* ── Results count ── */
    .results-info{font-size:13px;font-weight:700;color:#6b7280;padding:10px 16px 0}

    /* ── Responsive ── */
    @media(max-width:1200px){.stats-row{grid-template-columns:repeat(3,1fr)}}
    @media(max-width:992px){
      .main{margin-left:0;width:100%}
      .sidebar{transform:translateX(-100%)}
      .sidebar.show{transform:translateX(0)}
      .stats-row{grid-template-columns:repeat(2,1fr)}
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
      <a href="<%=request.getContextPath()%>/clerical/dashboard">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M3 13h8V3H3v10zM13 21h8V11h-8v10zM13 3h8v6h-8V3zM3 21h8v-6H3v6z" stroke="currentColor" stroke-width="2"/></svg>
        Overview
      </a>
      <div class="menu-label">Management</div>
      <a href="<%=request.getContextPath()%>/clerical/vehicle/requests">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M5 17H3v-5l2-5h14l2 5v5h-2" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><circle cx="7" cy="17" r="2" stroke="currentColor" stroke-width="2"/><circle cx="17" cy="17" r="2" stroke="currentColor" stroke-width="2"/></svg>
        Vehicle Approval
        <% if (pendingVehicles > 0) { %><span class="notif-badge"><%= pendingVehicles %></span><% } %>
      </a>
      <a class="active" href="<%=request.getContextPath()%>/clerical/summons/list">
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

      <!-- ── Page Header ── -->
      <div class="page-header">
        <div>
          <h1>All Summons Records</h1>
          <p>
            <% if (selectedYear > 0 && selectedMonth > 0) { %>
              Showing: <b><%= MONTH_NAMES[selectedMonth] %> <%= selectedYear %></b>
            <% } else if (selectedYear > 0) { %>
              Showing: <b>Year <%= selectedYear %></b>
            <% } else { %>
              Showing all summons — newest first
            <% } %>
          </p>
        </div>
        <% if (selectedYear > 0 || selectedMonth > 0) { %>
        <a href="<%=request.getContextPath()%>/clerical/summons/list" class="btn-clear">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M18 6L6 18M6 6l12 12" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
          Clear Filter
        </a>
        <% } %>
      </div>

      <!-- ── Filter Bar ── -->
      <form method="get" action="<%=request.getContextPath()%>/clerical/summons/list" class="filter-bar">
        <label>Year</label>
        <select name="year" class="filter-select">
          <option value="0">All Years</option>
          <% if (availableYears != null) { for (Integer yr : availableYears) { %>
          <option value="<%= yr %>" <%= yr == selectedYear ? "selected" : "" %>><%= yr %></option>
          <% } } %>
        </select>

        <label>Month</label>
        <select name="month" class="filter-select">
          <option value="0">All Months</option>
          <% String[] mNames = {"","January","February","March","April","May","June",
                                 "July","August","September","October","November","December"};
             for (int i = 1; i <= 12; i++) { %>
          <option value="<%= i %>" <%= i == selectedMonth ? "selected" : "" %>><%= mNames[i] %></option>
          <% } %>
        </select>

        <button type="submit" class="btn-filter">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M3 6h18M7 12h10M11 18h2" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
          Apply Filter
        </button>

        <% if (selectedYear > 0 || selectedMonth > 0) { %>
        <span class="filter-label-active">
          <% if (selectedYear > 0 && selectedMonth > 0) { %>
            <%= MONTH_NAMES[selectedMonth] %> <%= selectedYear %>
          <% } else if (selectedYear > 0) { %>
            Year <%= selectedYear %>
          <% } else { %>
            <%= MONTH_NAMES[selectedMonth] %> (All Years)
          <% } %>
        </span>
        <% } %>
      </form>

      <!-- ── Stats Row ── -->
      <div class="stats-row">
        <div class="stat-card c-total">
          <div class="stat-value"><%= totalSummons %></div>
          <div class="stat-label">Total</div>
        </div>
        <div class="stat-card c-unpaid">
          <div class="stat-value"><%= unpaidCount %></div>
          <div class="stat-label">Unpaid</div>
        </div>
        <div class="stat-card c-paid">
          <div class="stat-value"><%= paidCount %></div>
          <div class="stat-label">Paid</div>
        </div>
        <div class="stat-card c-appealed">
          <div class="stat-value"><%= appealedCount %></div>
          <div class="stat-label">Appealed</div>
        </div>
        <div class="stat-card c-overdue">
          <div class="stat-value"><%= overdueCount %></div>
          <div class="stat-label">Overdue</div>
        </div>
        <div class="stat-card c-amount">
          <div class="stat-value">RM <%= String.format("%.0f", unpaidAmt) %></div>
          <div class="stat-label">Outstanding</div>
        </div>
      </div>

      <!-- ── Search + Type/Status Filter ── -->
      <div class="table-controls">
        <input type="text" id="searchInput" class="search-input"
               placeholder="Search summons ID, offense, plate, matric, student..."
               oninput="filterTable()"/>
        <select id="filterType" class="filter-sel" onchange="filterTable()">
          <option value="">All Types</option>
          <option value="VEHICLE">Vehicle</option>
          <option value="MISCONDUCT">Misconduct</option>
        </select>
        <select id="filterStatus" class="filter-sel" onchange="filterTable()">
          <option value="">All Status</option>
          <option value="UNPAID">Unpaid</option>
          <option value="PAID">Paid</option>
          <option value="APPEALED">Appealed</option>
          <option value="OVERDUE">Overdue</option>
          <option value="WAIVED">Waived</option>
        </select>
        <span id="resultsCount" style="font-size:12px;font-weight:700;color:#9ca3af;white-space:nowrap"></span>
      </div>

      <!-- ── Table ── -->
      <div class="table-card">
        <div style="overflow-x:auto">
          <table id="summonsTable">
            <thead>
              <tr>
                <th>#</th>
                <th>Summons Details</th>
                <th>Type</th>
                <th>Student / Identifier</th>
                <th>Location</th>
                <th>Amount</th>
                <th>Issued Date</th>
                <th>Patrol Officer</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody id="tableBody">
              <% if (summonsList != null && !summonsList.isEmpty()) {
                   int rowNum = 0;
                   for (Summons sm : summonsList) {
                     rowNum++;
                     String statusClass = "pill-unpaid";
                     if ("PAID".equals(sm.getStatus()))     statusClass = "pill-paid";
                     if ("APPEALED".equals(sm.getStatus())) statusClass = "pill-appealed";
                     if ("OVERDUE".equals(sm.getStatus()))  statusClass = "pill-overdue";
                     if ("WAIVED".equals(sm.getStatus()))   statusClass = "pill-waived";
                     String typeClass  = "VEHICLE".equals(sm.getSummonsType()) ? "type-vehicle" : "type-misconduct";
                     String identifier = "VEHICLE".equals(sm.getSummonsType())
                                         ? sm.getPlateNumber() : sm.getMatricNo();
              %>
              <tr data-type="<%= sm.getSummonsType() %>"
                  data-status="<%= sm.getStatus() %>">
                <td style="font-size:12px;font-weight:700;color:#9ca3af"><%= rowNum %></td>
                <td>
                  <div class="summons-id"><%= sm.getSummonsId() %></div>
                  <div class="summons-offense">
                    <%= sm.getOffenseName() != null ? sm.getOffenseName() : sm.getSummonsType() %>
                  </div>
                </td>
                <td>
                  <span class="type-pill <%= typeClass %>"><%= sm.getSummonsType() %></span>
                </td>
                <td>
                  <div class="identifier"><%= identifier != null ? identifier : "—" %></div>
                  <div class="student-name">
                    <% if (sm.getPatrolStaffName() != null) { %>
                    Reported: <%= sm.getSummonsDate() %>
                    <% } %>
                  </div>
                </td>
                <td>
                  <div class="location-text" title="<%= sm.getLocation() != null ? sm.getLocation() : "" %>">
                    <%= sm.getLocation() != null ? sm.getLocation() : "—" %>
                  </div>
                </td>
                <td style="font-weight:950;color:#111827;font-size:14px">
                  RM <%= String.format("%.2f", sm.getAmount()) %>
                </td>
                <td style="font-size:13px;color:#374151;font-weight:700;white-space:nowrap">
                  <%= sm.getSummonsDate() %>
                </td>
                <td>
                  <div class="patrol-name"><%= sm.getPatrolStaffName() != null ? sm.getPatrolStaffName() : "—" %></div>
                  <div style="font-size:11px;color:#9ca3af;font-weight:600"><%= sm.getPatrolStaffId() %></div>
                </td>
                <td>
                  <span class="status-pill <%= statusClass %>"><%= sm.getStatus() %></span>
                </td>
              </tr>
              <% } } else { %>
              <tr>
                <td colspan="9">
                  <div class="empty-state">
                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none">
                      <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z" stroke="currentColor" stroke-width="2"/>
                      <path d="M14 2v6h6" stroke="currentColor" stroke-width="2"/>
                    </svg>
                    <p>No summons found
                      <% if (selectedYear > 0 || selectedMonth > 0) { %>
                        for the selected period.
                      <% } else { %>
                        in the system yet.
                      <% } %>
                    </p>
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
</div>

<script>
  const totalRows = <%= summonsList != null ? summonsList.size() : 0 %>;

  function filterTable() {
    const search  = document.getElementById("searchInput").value.toLowerCase();
    const type    = document.getElementById("filterType").value;
    const status  = document.getElementById("filterStatus").value;
    const rows    = document.querySelectorAll("#tableBody tr[data-type]");

    let visible = 0;
    rows.forEach(row => {
      const text      = row.textContent.toLowerCase();
      const rowType   = row.getAttribute("data-type");
      const rowStatus = row.getAttribute("data-status");

      const ok = (!search || text.includes(search))
              && (!type   || rowType   === type)
              && (!status || rowStatus === status);

      row.style.display = ok ? "" : "none";
      if (ok) visible++;
    });

    const countEl = document.getElementById("resultsCount");
    if (search || type || status) {
      countEl.textContent = visible + " of " + totalRows + " shown";
    } else {
      countEl.textContent = totalRows + " records";
    }
  }

  // Init count on load
  window.addEventListener("DOMContentLoaded", () => {
    document.getElementById("resultsCount").textContent = totalRows + " records";
  });

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
