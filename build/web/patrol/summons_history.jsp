<%-- 
    Document   : summons_history.jsp (Patrol Staff)
    Author     : SHAHRUL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.PatrolStaff"%>
<%@page import="model.Summons"%>
<%@page import="java.util.List"%>
<%
    PatrolStaff p = (PatrolStaff) session.getAttribute("patrol");
    if (p == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<Summons> summonsList = (List<Summons>) request.getAttribute("summonsList");

    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg   = (String) session.getAttribute("errorMsg");
    session.removeAttribute("successMsg");
    session.removeAttribute("errorMsg");

    int todayReports = 0;
    try {
        dao.SummonsDAO _sd = new dao.SummonsDAO();
        todayReports = _sd.countTodayByPatrol(p.getPatrolStaffId());
    } catch (Exception _e) {}
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Report History | Smart Campus</title>
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

    /* ── Shared Pills ── */
    .status-pill{font-size:10px;font-weight:950;text-transform:uppercase;letter-spacing:.08em;padding:5px 10px;border-radius:999px;display:inline-block}
    .pill-unpaid{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}
    .pill-paid{background:#f0fdf4;color:#16a34a;border:1px solid #dcfce7}
    .pill-appealed{background:#eff6ff;color:#2563eb;border:1px solid #dbeafe}
    .pill-overdue{background:#fef2f2;color:#dc2626;border:1px solid #fee2e2}
    .type-pill{font-size:10px;font-weight:950;text-transform:uppercase;padding:5px 10px;border-radius:999px;display:inline-block}
    .type-vehicle{background:#eff6ff;color:#2563eb;border:1px solid #dbeafe}
    .type-misconduct{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}

    /* ── Shared Alerts ── */
    .alert-success{background:#f0fdf4;border:1px solid #bbf7d0;color:#15803d;border-radius:14px;padding:12px 16px;font-weight:700;margin-bottom:16px}
    .alert-error{background:#fef2f2;border:1px solid #fecaca;color:#dc2626;border-radius:14px;padding:12px 16px;font-weight:700;margin-bottom:16px}

    /* ── Shared Empty State ── */
    .empty-state{text-align:center;padding:48px 20px;color:#9ca3af}
    .empty-state svg{opacity:.3;margin-bottom:12px;display:block;margin-left:auto;margin-right:auto}
    .empty-state p{font-weight:700;font-size:15px;margin:0}
    .empty-state a{color:#6f3cff;font-weight:900;text-decoration:none}

    /* ── Shared Page Header ── */
    .page-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:20px}
    .page-header h1{font-size:22px;font-weight:950;color:#111827;margin:0}
    .page-header p{font-size:13px;color:#6b7280;font-weight:700;margin:4px 0 0}

    /* ── Shared Buttons ── */
    .btn-back{display:inline-flex;align-items:center;gap:8px;background:#f3e8ff;color:#6f3cff;font-weight:900;padding:10px 16px;border-radius:14px;border:0;text-decoration:none}
    .btn-back:hover{background:#ede9fe;color:#6f3cff}

    /* ── Responsive ── */
    @media(max-width:992px){
      .main{margin-left:0;width:100%}
      .sidebar{transform:translateX(-100%)}
      .sidebar.show{transform:translateX(0)}
      .usertext{display:block}
    }

    /* ── Create Button ── */
    .btn-create{display:inline-flex;align-items:center;gap:8px;background:#6f3cff;color:#fff;font-weight:900;padding:10px 18px;border-radius:14px;border:0;text-decoration:none}
    .btn-create:hover{background:#5b21b6;color:#fff}

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

    /* ── Summons Cell ── */
    .summons-id{font-weight:950;color:#111827;font-size:13px}
    .summons-offense{font-size:12px;color:#6b7280;font-weight:600;margin-top:2px}
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
      <a href="<%=request.getContextPath()%>/patrol/dashboard">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M3 13h8V3H3v10zM13 21h8V11h-8v10zM13 3h8v6h-8V3zM3 21h8v-6H3v6z" stroke="currentColor" stroke-width="2"/></svg>
        Overview
      </a>
      <div class="menu-label">Summons</div>
      <a href="<%=request.getContextPath()%>/patrol/summons/create">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
        Create Summons
      </a>
      <a class="active" href="<%=request.getContextPath()%>/patrol/summons/history">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M4 4h16v16H4V4z" stroke="currentColor" stroke-width="2"/><path d="M8 8h8M8 12h8M8 16h4" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
        My Report History
        <% if (todayReports > 0) { %><span class="notif-badge"><%= todayReports %></span><% } %>
      </a>
    </nav>
    <div class="sidebar-bottom">
      <button class="logout-btn" onclick="window.location.href='<%=request.getContextPath()%>/patrol/logout'">
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
      <div class="portal-title">PATROL Portal</div>
      <div class="userbox">
        <div class="avatar"><%= p.getPatrolName().substring(0,1).toUpperCase() %></div>
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

      <!-- Page Header -->
      <div class="page-header">
        <div>
          <h1>My Report History</h1>
          <p>All summons reports submitted by you.</p>
        </div>
        <a href="<%=request.getContextPath()%>/patrol/summons/create" class="btn-create">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
            <path d="M12 5v14M5 12h14" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/>
          </svg>
          New Summons
        </a>
      </div>

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

      <!-- Table -->
      <div class="table-card">
        <div style="overflow-x:auto">
          <table id="summonsTable">
            <thead>
              <tr>
                <th>Summons</th>
                <th>Type</th>
                <th>Identifier</th>
                <th>Location</th>
                <th>Amount</th>
                <th>Date</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody id="tableBody">
              <% if (summonsList != null && !summonsList.isEmpty()) {
                   for (Summons s : summonsList) {
                     String pillClass = "pill-unpaid";
                     if ("PAID".equals(s.getStatus()))     pillClass = "pill-paid";
                     if ("APPEALED".equals(s.getStatus())) pillClass = "pill-appealed";
                     if ("OVERDUE".equals(s.getStatus()))  pillClass = "pill-overdue";
              %>
              <tr data-type="<%= s.getSummonsType() %>"
                  data-status="<%= s.getStatus() %>">
                <td>
                  <div class="summons-id"><%= s.getSummonsId() %></div>
                  <% if (s.getOffenseName() != null) { %>
                  <div class="summons-offense"><%= s.getOffenseName() %></div>
                  <% } %>
                </td>
                <td>
                  <span class="type-pill <%= "VEHICLE".equals(s.getSummonsType()) 
                    ? "type-vehicle" : "type-misconduct" %>">
                    <%= s.getSummonsType() %>
                  </span>
                </td>
                <td style="font-weight:700;color:#374151;font-size:13px">
                  <% if ("VEHICLE".equals(s.getSummonsType())) { %>
                    <%= s.getPlateNumber() %>
                  <% } else { %>
                    <%= s.getMatricNo() %>
                  <% } %>
                </td>
                <td style="font-size:13px;color:#6b7280;font-weight:600;max-width:160px">
                  <%= s.getLocation() %>
                </td>
                <td style="font-weight:950;color:#111827">
                  RM <%= String.format("%.2f", s.getAmount()) %>
                </td>
                <td style="font-size:12px;color:#6b7280;font-weight:700">
                  <%= s.getSummonsDate() %>
                </td>
                <td>
                  <span class="status-pill <%= pillClass %>">
                    <%= s.getStatus() %>
                  </span>
                </td>
              </tr>
              <% } } else { %>
              <tr>
                <td colspan="7">
                  <div class="empty-state">
                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none">
                      <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z"
                            stroke="currentColor" stroke-width="2"/>
                      <path d="M14 2v6h6" stroke="currentColor" stroke-width="2"/>
                    </svg>
                    <p>No reports yet. 
                      <a href="<%=request.getContextPath()%>/patrol/summons/create">
                        Create your first summons
                      </a>
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
