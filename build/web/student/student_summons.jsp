<%-- 
    Document   : summons.jsp (Student)
    Author     : SHAHRUL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Student"%>
<%@page import="model.Summons"%>
<%@page import="java.util.List"%>
<%
    Student s = (Student) session.getAttribute("student");
    if (s == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<Summons> summonsList     = (List<Summons>) request.getAttribute("summonsList");
    int    totalSummons           = request.getAttribute("totalSummons")    != null ? (int)    request.getAttribute("totalSummons")    : 0;
    int    unpaidSummons          = request.getAttribute("unpaidSummons")   != null ? (int)    request.getAttribute("unpaidSummons")   : 0;
    int    paidSummons            = request.getAttribute("paidSummons")     != null ? (int)    request.getAttribute("paidSummons")     : 0;
    int    appealedSummons        = request.getAttribute("appealedSummons") != null ? (int)    request.getAttribute("appealedSummons") : 0;
    double outstanding            = request.getAttribute("outstanding")     != null ? (double) request.getAttribute("outstanding")     : 0.0;

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
  <title>My Summons | Smart Campus</title>
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

    /* ── Shared Pills ── */
    .status-pill{font-size:10px;font-weight:950;text-transform:uppercase;letter-spacing:.08em;padding:5px 10px;border-radius:999px;display:inline-block}
    .pill-unpaid{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}
    .pill-paid{background:#f0fdf4;color:#16a34a;border:1px solid #dcfce7}
    .pill-appealed{background:#eff6ff;color:#2563eb;border:1px solid #dbeafe}
    .pill-waived{background:#fdf4ff;color:#9333ea;border:1px solid #f3e8ff}
    .pill-overdue{background:#fef2f2;color:#dc2626;border:1px solid #fee2e2}
    .pill-pending{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}
    .pill-approved{background:#f0fdf4;color:#16a34a;border:1px solid #dcfce7}
    .pill-rejected{background:#fef2f2;color:#dc2626;border:1px solid #fee2e2}

    /* ── Shared Alert Banners ── */
    .alert-success{background:#f0fdf4;border:1px solid #bbf7d0;color:#15803d;border-radius:14px;padding:12px 16px;font-weight:700;margin-bottom:16px}
    .alert-error{background:#fef2f2;border:1px solid #fecaca;color:#dc2626;border-radius:14px;padding:12px 16px;font-weight:700;margin-bottom:16px}
    .alert-unpaid{background:#fff7ed;border:1px solid #ffedd5;border-radius:16px;padding:14px 18px;margin-bottom:16px;display:flex;align-items:center;gap:12px}
    .alert-unpaid svg{color:#ea580c;flex-shrink:0}
    .alert-unpaid-text{font-weight:700;color:#ea580c;font-size:14px}

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
    .btn-purple{background:#6f3cff;border:0;color:#fff;font-weight:900;border-radius:14px;padding:10px 14px;box-shadow:0 12px 26px rgba(111,60,255,.18);text-decoration:none;display:inline-flex;align-items:center;gap:10px}
    .btn-purple:hover{background:#5f2df0;color:#fff}
    .btn-soft{border:0;background:#f3e8ff;color:#6f3cff;font-weight:950;padding:10px 14px;border-radius:14px;text-decoration:none;display:inline-flex;align-items:center;gap:10px}
    .btn-soft:hover{background:#ede9fe;color:#6f3cff}

    /* ── Shared Card ── */
    .cardx{background:#fff;border:1px solid #e5e7eb;border-radius:26px;padding:18px;box-shadow:0 6px 18px rgba(17,24,39,.04)}

    /* ── Responsive ── */
    @media(max-width:992px){
      .main{margin-left:0;width:100%}
      .sidebar{transform:translateX(-100%)}
      .sidebar.show{transform:translateX(0)}
      .stats-row{grid-template-columns:repeat(2,1fr)}
      .outstanding-banner{flex-direction:column;align-items:flex-start;gap:12px}
      .usertext{display:block}
    }

    /* ── Stats Row ── */
    .stats-row{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:20px}
    .stat-card{background:#fff;border:1px solid #e5e7eb;border-radius:20px;padding:18px 20px;box-shadow:0 4px 12px rgba(17,24,39,.04);text-align:center}
    .stat-value{font-size:28px;font-weight:950;color:#111827}
    .stat-label{font-size:11px;font-weight:900;color:#6b7280;text-transform:uppercase;letter-spacing:.10em;margin-top:4px}
    .stat-unpaid .stat-value{color:#ea580c}
    .stat-paid .stat-value{color:#16a34a}
    .stat-appealed .stat-value{color:#2563eb}
    .stat-total .stat-value{color:#6f3cff}

    /* ── Outstanding Banner ── */
    .outstanding-banner{
      background:linear-gradient(135deg,#6f3cff,#4338ca);
      border-radius:20px;padding:20px 24px;color:#fff;
      display:flex;align-items:center;justify-content:space-between;
      margin-bottom:20px;
    }
    .outstanding-banner h3{margin:0;font-weight:950;font-size:18px}
    .outstanding-banner p{margin:4px 0 0;color:#e9d5ff;font-weight:600;font-size:13px}
    .outstanding-amt{font-size:32px;font-weight:950;color:#fff}
    .outstanding-label{font-size:12px;color:#e9d5ff;font-weight:700;text-align:right}

    /* ── Filter Bar ── */
    .filter-bar{background:#fff;border:1px solid #e5e7eb;border-radius:18px;padding:14px 18px;margin-bottom:18px;display:flex;align-items:center;gap:12px;flex-wrap:wrap}
    .filter-bar input,.filter-bar select{border:1px solid #e5e7eb;border-radius:10px;padding:8px 12px;font-weight:700;color:#374151;background:#f9fafb;font-size:13px;outline:none}
    .filter-bar input:focus,.filter-bar select:focus{border-color:#6f3cff;background:#fff}

    /* ── Table Card ── */
    .table-card{background:#fff;border:1px solid #e5e7eb;border-radius:20px;box-shadow:0 4px 12px rgba(17,24,39,.04);overflow:hidden}
    .table-card table{width:100%;border-collapse:collapse;min-width:600px}
    .table-card thead{background:#f9fafb}
    .table-card th{font-size:11px;text-transform:uppercase;letter-spacing:.12em;color:#6b7280;font-weight:950;padding:14px 16px;border-bottom:1px solid #f1f5f9}
    .table-card td{padding:14px 16px;border-bottom:1px solid #f1f5f9;vertical-align:middle}
    .table-card tr:last-child td{border-bottom:0}
    .table-card tr:hover td{background:#fafafa}

    /* ── Type Pills ── */
    .type-pill{font-size:10px;font-weight:950;text-transform:uppercase;padding:5px 10px;border-radius:999px;display:inline-block}
    .type-vehicle{background:#eff6ff;color:#2563eb;border:1px solid #dbeafe}
    .type-misconduct{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}

    /* ── Summons Cell ── */
    .summons-id{font-weight:950;color:#111827;font-size:13px}
    .summons-offense{font-size:12px;color:#6b7280;font-weight:600;margin-top:2px}
    .summons-location{font-size:11px;color:#9ca3af;font-weight:600;margin-top:2px}

    /* ── Action Buttons ── */
    .btn-details{border:0;background:#f3e8ff;color:#6f3cff;font-weight:950;padding:7px 12px;border-radius:10px;font-size:12px;cursor:pointer;transition:.15s;text-decoration:none;display:inline-block}
    .btn-details:hover{background:#ede9fe;color:#6f3cff}

    /* ── Modal ── */
    .modal-overlay{position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:100;display:none;align-items:center;justify-content:center}
    .modal-overlay.show{display:flex}
    .modal-box{background:#fff;border-radius:24px;padding:28px;width:100%;max-width:520px;box-shadow:0 25px 50px rgba(0,0,0,.15);max-height:90vh;overflow-y:auto}
    .modal-title{font-size:20px;font-weight:950;color:#111827;margin-bottom:4px}
    .modal-sub{font-size:13px;color:#6b7280;font-weight:700;margin-bottom:20px}
    .detail-row{display:flex;justify-content:space-between;padding:10px 0;border-bottom:1px solid #f1f5f9}
    .detail-row:last-child{border-bottom:0}
    .detail-label{font-size:12px;font-weight:900;color:#6b7280;text-transform:uppercase;letter-spacing:.08em}
    .detail-value{font-size:14px;font-weight:950;color:#111827;text-align:right}
    .btn-close-modal{border:1.5px solid #e5e7eb;background:#fff;color:#374151;font-weight:900;padding:10px 20px;border-radius:12px;cursor:pointer;width:100%;margin-top:16px}
    .btn-close-modal:hover{background:#f9fafb}
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
      <a href="<%=request.getContextPath()%>/student/dashboard">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M3 13h8V3H3v10zM13 21h8V11h-8v10zM13 3h8v6h-8V3zM3 21h8v-6H3v6z" stroke="currentColor" stroke-width="2"/></svg>
        Overview
      </a>
      <div class="menu-label">My Records</div>
      <a href="<%=request.getContextPath()%>/student/vehicles">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M5 17H3v-5l2-5h14l2 5v5h-2" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><circle cx="7" cy="17" r="2" stroke="currentColor" stroke-width="2"/><circle cx="17" cy="17" r="2" stroke="currentColor" stroke-width="2"/></svg>
        My Vehicles
      </a>
      <a class="active" href="<%=request.getContextPath()%>/student/summons">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z" stroke="currentColor" stroke-width="2"/><path d="M14 2v6h6" stroke="currentColor" stroke-width="2"/></svg>
        My Summons
        <% if (unpaidSummons > 0) { %><span class="notif-badge"><%= unpaidSummons %></span><% } %>
      </a>
      <a href="<%=request.getContextPath()%>/student/appeal/list">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z" stroke="currentColor" stroke-width="2" stroke-linejoin="round"/></svg>
        My Appeals
      </a>
      <a href="<%=request.getContextPath()%>/student/payment/receipts">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><rect width="20" height="14" x="2" y="5" rx="2" stroke="currentColor" stroke-width="2"/><path d="M2 10h20" stroke="currentColor" stroke-width="2"/></svg>
        My Receipts
      </a>
      <div class="menu-label">Account</div>
      <a href="<%=request.getContextPath()%>/student/profile">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M20 21a8 8 0 10-16 0" stroke="currentColor" stroke-width="2"/><path d="M12 11a4 4 0 100-8 4 4 0 000 8z" stroke="currentColor" stroke-width="2"/></svg>
        Profile
      </a>
    </nav>
    <div class="sidebar-bottom">
      <button class="logout-btn" onclick="window.location.href='<%=request.getContextPath()%>/logout'">
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
      <div class="portal-title">STUDENT Portal</div>
      <div class="header-right">
        <div class="userbox">
          <div class="usertext">
            <div style="font-weight:900;color:#111827;font-size:14px"><%= s.getStudentName() %></div>
            <div style="font-size:11px;color:#6b7280;font-weight:900;letter-spacing:.10em;text-transform:uppercase">
              <%= s.getMatricNo() %>
            </div>
          </div>
          <div class="avatar"><%= s.getStudentName().substring(0,1).toUpperCase() %></div>
        </div>
      </div>
    </header>

    <div class="content">

      <!-- Alerts -->
      <% if (successMsg != null) { %>
        <div class="alert-success">✓ <%= successMsg %></div>
      <% } %>
      <% if (errorMsg != null) { %>
        <div class="alert-error">✕ <%= errorMsg %></div>
      <% } %>

      <!-- Unpaid warning -->
      <% if (unpaidSummons > 0) { %>
      <div class="alert-unpaid">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" style="color:#ea580c;flex-shrink:0">
          <path d="M12 9v4m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"
                stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
        </svg>
        <div class="alert-unpaid-text">
          You have <b><%= unpaidSummons %></b> unpaid summons totalling 
          <b>RM <%= String.format("%.2f", outstanding) %></b>. 
          Please settle them to avoid penalties.
        </div>
      </div>
      <% } %>

      <!-- Page Header -->
      <div class="page-header">
        <div>
          <h1>My Summons</h1>
          <p>View and manage all your disciplinary and vehicle summons.</p>
        </div>
      </div>

      <!-- Stats Row -->
      <div class="stats-row">
        <div class="stat-card stat-total">
          <div class="stat-value"><%= totalSummons %></div>
          <div class="stat-label">Total</div>
        </div>
        <div class="stat-card stat-unpaid">
          <div class="stat-value"><%= unpaidSummons %></div>
          <div class="stat-label">Unpaid</div>
        </div>
        <div class="stat-card stat-paid">
          <div class="stat-value"><%= paidSummons %></div>
          <div class="stat-label">Paid</div>
        </div>
        <div class="stat-card stat-appealed">
          <div class="stat-value"><%= appealedSummons %></div>
          <div class="stat-label">Appealed</div>
        </div>
      </div>

      <!-- Outstanding Banner -->
      <% if (outstanding > 0) { %>
      <div class="outstanding-banner">
        <div>
          <h3>Outstanding Balance</h3>
          <p>Please settle your unpaid summons as soon as possible.</p>
        </div>
        <div>
          <div class="outstanding-amt">RM <%= String.format("%.2f", outstanding) %></div>
          <div class="outstanding-label"><%= unpaidSummons %> unpaid summons</div>
        </div>
      </div>
      <% } %>

      <!-- Filter Bar -->
      <div class="filter-bar">
        <input type="text" id="searchInput" placeholder="Search summons ID or offense..."
               oninput="filterTable()" style="flex:1;min-width:180px"/>
        <select id="filterType" onchange="filterTable()">
          <option value="">All Types</option>
          <option value="VEHICLE">Vehicle</option>
          <option value="MISCONDUCT">Misconduct</option>
        </select>
        <select id="filterStatus" onchange="filterTable()">
          <option value="">All Status</option>
          <option value="UNPAID">Unpaid</option>
          <option value="PAID">Paid</option>
          <option value="APPEALED">Appealed</option>
          <option value="OVERDUE">Overdue</option>
        </select>
      </div>

      <!-- Summons Table -->
      <div class="table-card">
        <div style="overflow-x:auto">
          <table id="summonsTable">
            <thead>
              <tr>
                <th>Summons Details</th>
                <th>Type</th>
                <th>Date</th>
                <th>Amount</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody id="tableBody">
              <% if (summonsList != null && !summonsList.isEmpty()) {
                   for (Summons sm : summonsList) {
                     String pillClass = "pill-unpaid";
                     if ("PAID".equals(sm.getStatus()))     pillClass = "pill-paid";
                     if ("APPEALED".equals(sm.getStatus())) pillClass = "pill-appealed";
                     if ("OVERDUE".equals(sm.getStatus()))  pillClass = "pill-overdue";

                     String typeClass = "VEHICLE".equals(sm.getSummonsType()) 
                                        ? "type-vehicle" : "type-misconduct";

                     // Build data for modal
                     String identifier = "VEHICLE".equals(sm.getSummonsType())
                                         ? sm.getPlateNumber() 
                                         : sm.getMatricNo();
              %>
              <tr data-type="<%= sm.getSummonsType() %>"
                  data-status="<%= sm.getStatus() %>"
                  data-id="<%= sm.getSummonsId() %>"
                  data-offense="<%= sm.getOffenseName() != null ? sm.getOffenseName() : "" %>"
                  data-amount="<%= String.format("%.2f", sm.getAmount()) %>"
                  data-date="<%= sm.getSummonsDate() %>"
                  data-location="<%= sm.getLocation() != null ? sm.getLocation() : "" %>"
                  data-identifier="<%= identifier != null ? identifier : "" %>"
                  data-description="<%= sm.getDescription() != null ? sm.getDescription() : "" %>"
                  data-evidence="<%= sm.getEvidencePath() != null ? (request.getContextPath() + "/" + sm.getEvidencePath()) : "" %>">
                <td>
                  <div class="summons-id"><%= sm.getSummonsId() %></div>
                  <div class="summons-offense">
                    <%= sm.getOffenseName() != null ? sm.getOffenseName() : sm.getSummonsType() %>
                  </div>
                  <% if (sm.getLocation() != null && !sm.getLocation().isEmpty()) { %>
                  <div class="summons-location">📍 <%= sm.getLocation() %></div>
                  <% } %>
                </td>
                <td>
                  <span class="type-pill <%= typeClass %>">
                    <%= sm.getSummonsType() %>
                  </span>
                </td>
                <td style="font-size:13px;color:#6b7280;font-weight:700">
                  <%= sm.getSummonsDate() %>
                </td>
                <td style="font-weight:950;color:#111827;font-size:15px">
                  RM <%= String.format("%.2f", sm.getAmount()) %>
                </td>
                <td>
                  <span class="status-pill <%= pillClass %>">
                    <%= sm.getStatus() %>
                  </span>
                </td>
                <td>
                  <div style="display:flex;gap:6px;flex-wrap:wrap">
                    <button class="btn-details" onclick="showDetails(this)">
                      Details
                    </button>
                    <% if ("UNPAID".equals(sm.getStatus())) { %>
                    <a href="<%=request.getContextPath()%>/student/payment/pay?id=<%= sm.getSummonsId() %>"
                       style="border:0;background:#f0fdf4;color:#16a34a;font-weight:950;
                              padding:7px 12px;border-radius:10px;font-size:12px;
                              text-decoration:none;display:inline-block;transition:.15s"
                       onmouseover="this.style.background='#dcfce7'"
                       onmouseout="this.style.background='#f0fdf4'">
                      Pay
                    </a>
                    <% } %>
                    <% if ("UNPAID".equals(sm.getStatus())) { %>
                    <a href="<%=request.getContextPath()%>/student/appeal/submit?id=<%= sm.getSummonsId() %>"
                       style="border:0;background:#f0fdf4;color:#2563eb;font-weight:950;
                              padding:7px 12px;border-radius:10px;font-size:12px;
                              text-decoration:none;display:inline-block;transition:.15s"
                       onmouseover="this.style.background='#dcfce7'"
                       onmouseout="this.style.background='#f0fdf4'">
                      Appeal
                    </a>
                    <% } %>
                  </div>
                </td>
              </tr>
              <% } } else { %>
              <tr>
                <td colspan="6">
                  <div class="empty-state">
                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none">
                      <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z"
                            stroke="currentColor" stroke-width="2"/>
                      <path d="M14 2v6h6" stroke="currentColor" stroke-width="2"/>
                    </svg>
                    <p>You have no summons. Keep it up! 🎉</p>
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

<!-- ══════════ DETAILS MODAL ══════════ -->
<div class="modal-overlay" id="detailModal">
  <div class="modal-box">
    <div class="modal-title" id="modalSummonsId">Summons Details</div>
    <div class="modal-sub">Full details of your summons record</div>

    <div class="detail-row">
      <div class="detail-label">Offense</div>
      <div class="detail-value" id="modalOffense">-</div>
    </div>
    <div class="detail-row">
      <div class="detail-label">Type</div>
      <div class="detail-value" id="modalType">-</div>
    </div>
    <div class="detail-row">
      <div class="detail-label">Identifier</div>
      <div class="detail-value" id="modalIdentifier">-</div>
    </div>
    <div class="detail-row">
      <div class="detail-label">Date</div>
      <div class="detail-value" id="modalDate">-</div>
    </div>
    <div class="detail-row">
      <div class="detail-label">Location</div>
      <div class="detail-value" id="modalLocation">-</div>
    </div>
    <div class="detail-row">
      <div class="detail-label">Fine Amount</div>
      <div class="detail-value" id="modalAmount" style="color:#ea580c;font-size:18px">-</div>
    </div>
    <div class="detail-row">
      <div class="detail-label">Status</div>
      <div class="detail-value" id="modalStatus">-</div>
    </div>
    <div class="detail-row" id="modalDescRow">
      <div class="detail-label">Notes</div>
      <div class="detail-value" id="modalDesc" style="max-width:280px;text-align:right">-</div>
    </div>

    <div id="modalEvidenceRow" style="margin-top:14px">
      <div class="detail-label" style="margin-bottom:8px">Evidence Photo</div>
      <a id="modalEvidenceLink" href="#" target="_blank" rel="noopener">
        <img id="modalEvidenceImg" src="" alt="Evidence photo"
             style="width:100%;max-height:280px;object-fit:cover;border-radius:14px;
                    border:1px solid #e5e7eb;display:block">
      </a>
    </div>

    <button class="btn-close-modal" onclick="closeModal()">Close</button>
  </div>
</div>

<script>
  // ── Filter table ──
  function filterTable() {
    const search = document.getElementById("searchInput").value.toLowerCase();
    const type   = document.getElementById("filterType").value;
    const status = document.getElementById("filterStatus").value;
    const rows   = document.querySelectorAll("#tableBody tr[data-type]");

    rows.forEach(row => {
      const text      = row.textContent.toLowerCase();
      const rowType   = row.getAttribute("data-type");
      const rowStatus = row.getAttribute("data-status");

      const matchSearch = text.includes(search);
      const matchType   = !type   || rowType   === type;
      const matchStatus = !status || rowStatus === status;

      row.style.display = (matchSearch && matchType && matchStatus) ? "" : "none";
    });
  }

  // ── Show details modal ──
  function showDetails(btn) {
    const row = btn.closest("tr");

    const id          = row.getAttribute("data-id");
    const offense     = row.getAttribute("data-offense");
    const type        = row.getAttribute("data-type");
    const identifier  = row.getAttribute("data-identifier");
    const date        = row.getAttribute("data-date");
    const location    = row.getAttribute("data-location");
    const amount      = row.getAttribute("data-amount");
    const status      = row.getAttribute("data-status");
    const description = row.getAttribute("data-description");
    const evidence     = row.getAttribute("data-evidence");

    document.getElementById("modalSummonsId").textContent  = id;
    document.getElementById("modalOffense").textContent    = offense   || "-";
    document.getElementById("modalType").textContent       = type      || "-";
    document.getElementById("modalIdentifier").textContent = identifier || "-";
    document.getElementById("modalDate").textContent       = date      || "-";
    document.getElementById("modalLocation").textContent   = location  || "-";
    document.getElementById("modalAmount").textContent     = "RM " + amount;
    document.getElementById("modalDesc").textContent       = description || "-";

    // Show/hide evidence photo
    const evidenceRow = document.getElementById("modalEvidenceRow");
    if (evidence) {
      document.getElementById("modalEvidenceImg").src  = evidence;
      document.getElementById("modalEvidenceLink").href = evidence;
      evidenceRow.style.display = "";
    } else {
      evidenceRow.style.display = "none";
    }

    // Status pill
    let pillHtml = "<span class='status-pill ";
    if (status === "PAID")     pillHtml += "pill-paid";
    else if (status === "APPEALED") pillHtml += "pill-appealed";
    else if (status === "OVERDUE")  pillHtml += "pill-overdue";
    else                            pillHtml += "pill-unpaid";
    pillHtml += "'>" + status + "</span>";
    document.getElementById("modalStatus").innerHTML = pillHtml;

    // Show/hide description row
    document.getElementById("modalDescRow").style.display = 
      description ? "" : "none";

    document.getElementById("detailModal").classList.add("show");
  }

  function closeModal() {
    document.getElementById("detailModal").classList.remove("show");
  }

  // Close modal on outside click
  document.getElementById("detailModal").addEventListener("click", function(e) {
    if (e.target === this) closeModal();
  });

  // ── Sidebar ──
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
