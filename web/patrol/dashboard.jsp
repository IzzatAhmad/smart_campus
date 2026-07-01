<%-- 
    Document   : dashboard.jsp (Patrol Staff)
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

    String currentPage = request.getRequestURI();

    // ── Real stats from servlet ──
    int totalReports   = request.getAttribute("totalReports")   != null ? (int) request.getAttribute("totalReports")   : 0;
    int todayReports   = request.getAttribute("todayReports")   != null ? (int) request.getAttribute("todayReports")   : 0;
    int pendingReports = request.getAttribute("pendingReports") != null ? (int) request.getAttribute("pendingReports") : 0;

    // ── Recent summons from servlet ──
    List<Summons> recentList = (List<Summons>) request.getAttribute("recentList");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Patrol Dashboard | Smart Campus</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

  <style>
    /* ── Reset & Base ── */
    *,*::before,*::after{box-sizing:border-box}
    html,body{margin:0;padding:0;height:100%;background:#f5f6fb;font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif}

    /* ── App Shell ── */
    .app{min-height:100vh;background:#f5f6fb}

    /* ── Sidebar ── */
    .sidebar{
      width:260px;background:#f5f0ff;border-right:1px solid #e4d9f7;
      position:fixed;top:0;left:0;bottom:0;z-index:30;
      transform:translateX(-100%);
      transition:transform .25s ease;
      display:flex;flex-direction:column;
      overflow-y:auto;
    }
    .sidebar.show{transform:translateX(0)}
    @media(min-width:993px){
      .sidebar{transform:translateX(0)}
      .main{margin-left:260px}
    }
    .brand{display:flex;gap:12px;align-items:center;padding:24px 20px 18px}
    .brand-badge{width:40px;height:40px;border-radius:12px;background:#7c3aed;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:900;font-size:20px;box-shadow:0 8px 24px rgba(124,58,237,.30);flex-shrink:0}
    .brand-title{font-weight:900;color:#3b1c86;line-height:1.1}
    .brand-sub{font-size:.75rem;color:#7c3aed;font-weight:700}
    .menu{padding:10px 14px;display:flex;flex-direction:column;gap:4px}
    .menu a{text-decoration:none;display:flex;align-items:center;gap:12px;padding:11px 14px;border-radius:12px;color:#5b21b6;font-weight:700;transition:.15s}
    .menu a:hover{background:#ede9fe;color:#4c1d95}
    .menu a.active{background:#7c3aed;color:#fff;box-shadow:0 4px 14px rgba(124,58,237,.25)}
    .menu a.active svg,.menu a:hover svg{opacity:1}
    .menu svg{opacity:.7}
    .menu-label{font-size:10px;font-weight:900;letter-spacing:.12em;text-transform:uppercase;color:#a78bfa;padding:10px 14px 4px}
    .notif-badge{margin-left:auto;background:#ef4444;color:#fff;font-size:10px;font-weight:950;padding:2px 8px;border-radius:999px;display:inline-block;flex-shrink:0}
    .sidebar-bottom{margin-top:auto;padding:14px;border-top:1px solid #e4d9f7}
    .logout-btn{width:100%;border:0;background:#f5f0ff;color:#dc2626;font-weight:900;padding:12px 14px;border-radius:12px;text-align:left;cursor:pointer;display:flex;align-items:center;gap:10px;font-size:14px}
    .logout-btn:hover{background:#fef2f2}

    /* ── Overlay ── */
    .overlay{position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:20;display:none}
    .overlay.show{display:block}

    /* ── Main ── */
    .main{min-height:100vh;display:flex;flex-direction:column;background:#f5f6fb}

    /* ── Header ── */
    .header{height:60px;background:#fff;border-bottom:1px solid #e5e7eb;display:flex;align-items:center;justify-content:space-between;padding:0 16px;position:sticky;top:0;z-index:10;box-shadow:0 1px 4px rgba(0,0,0,.05)}
    .hamburger{border:0;background:transparent;padding:8px;border-radius:10px;cursor:pointer;display:flex;align-items:center;color:#374151}
    .hamburger:hover{background:#f3f4f6}
    .portal-title{font-weight:800;color:#111827;font-size:15px}
    .header-right{display:flex;align-items:center;gap:10px}
    .userbox{display:flex;align-items:center;gap:10px;padding-left:10px;border-left:1px solid #f1f5f9}
    .usertext{display:none;text-align:right}
    .avatar{width:36px;height:36px;border-radius:999px;background:#ede9fe;color:#6f3cff;display:flex;align-items:center;justify-content:center;font-weight:900;font-size:15px;flex-shrink:0}

    /* ── Content ── */
    .content{padding:14px;flex:1}

    /* ── Pills ── */
    .status-pill{font-size:10px;font-weight:950;text-transform:uppercase;letter-spacing:.06em;padding:4px 9px;border-radius:999px;display:inline-block;white-space:nowrap}
    .pill-unpaid{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}
    .pill-paid{background:#f0fdf4;color:#16a34a;border:1px solid #dcfce7}
    .pill-appealed{background:#eff6ff;color:#2563eb;border:1px solid #dbeafe}
    .pill-overdue{background:#fef2f2;color:#dc2626;border:1px solid #fee2e2}
    .type-vehicle{background:#eff6ff;color:#2563eb;border:1px solid #dbeafe}
    .type-misconduct{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}

    /* ── Alerts ── */
    .alert-success{background:#f0fdf4;border:1px solid #bbf7d0;color:#15803d;border-radius:14px;padding:12px 16px;font-weight:700;margin-bottom:16px}
    .alert-error{background:#fef2f2;border:1px solid #fecaca;color:#dc2626;border-radius:14px;padding:12px 16px;font-weight:700;margin-bottom:16px}

    /* ── Empty State ── */
    .empty-state{text-align:center;padding:36px 20px;color:#9ca3af}
    .empty-state svg{opacity:.3;margin-bottom:10px;display:block;margin-inline:auto}
    .empty-state p{font-weight:700;font-size:14px;margin:0}
    .empty-state a{color:#6f3cff;font-weight:900;text-decoration:none}

    /* ── Page Header ── */
    .page-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:16px;flex-wrap:wrap;gap:10px}
    .page-header h1{font-size:20px;font-weight:950;color:#111827;margin:0}
    .page-header p{font-size:13px;color:#6b7280;font-weight:700;margin:4px 0 0}
    .btn-back{display:inline-flex;align-items:center;gap:8px;background:#f3e8ff;color:#6f3cff;font-weight:900;padding:9px 14px;border-radius:12px;border:0;text-decoration:none;font-size:13px}
    .btn-back:hover{background:#ede9fe;color:#6f3cff}

    /* ── Welcome Banner ── */
    .welcome{background:linear-gradient(135deg,#7c3aed,#4338ca);border-radius:20px;padding:20px;color:#fff;position:relative;overflow:hidden;margin-bottom:14px}
    .welcome h2{margin:0 0 6px;font-weight:950;font-size:19px;line-height:1.2}
    .welcome p{margin:0 0 14px;color:#e9d5ff;font-weight:600;font-size:13px;line-height:1.5}
    .welcome-icon{position:absolute;right:-10px;top:8px;opacity:.12;pointer-events:none}
    .btn-white{display:inline-flex;align-items:center;gap:8px;background:#fff;color:#6f3cff;font-weight:900;padding:10px 16px;border-radius:12px;border:0;cursor:pointer;text-decoration:none;font-size:13px}
    .btn-white:hover{background:#faf5ff;color:#6f3cff}

    /* ── Stats Row ── */
    .stats-row{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;margin-bottom:14px}
    .stat-card{background:#fff;border:1px solid #e5e7eb;border-radius:16px;padding:14px 10px;box-shadow:0 2px 8px rgba(17,24,39,.05)}
    .stat-icon{width:36px;height:36px;border-radius:10px;display:flex;align-items:center;justify-content:center;margin-bottom:8px}
    .icon-purple{background:#f3e8ff;color:#6f3cff}
    .icon-blue{background:#eff6ff;color:#2563eb}
    .icon-orange{background:#fff7ed;color:#ea580c}
    .stat-value{font-size:22px;font-weight:950;color:#111827;line-height:1}
    .stat-label{font-size:9px;font-weight:900;color:#6b7280;text-transform:uppercase;letter-spacing:.06em;margin-top:4px;line-height:1.3}

    /* ── Grid Bottom ── */
    .grid-bottom{display:grid;grid-template-columns:1fr;gap:12px}

    /* ── Card ── */
    .card{background:#fff;border:1px solid #e5e7eb;border-radius:18px;padding:16px;box-shadow:0 2px 8px rgba(17,24,39,.05)}
    .card-title{font-size:15px;font-weight:950;color:#111827;margin-bottom:14px;display:flex;align-items:center;justify-content:space-between}
    .view-all{font-size:12px;font-weight:900;color:#6f3cff;text-decoration:none}
    .view-all:hover{color:#5b21b6}

    /* ── Quick Actions ── */
    .quick-actions{display:flex;flex-direction:column;gap:10px}
    .action-item{display:flex;align-items:center;gap:12px;padding:12px 14px;border-radius:14px;border:1.5px solid #e5e7eb;background:#fafafa;text-decoration:none;color:#111827;font-weight:700;transition:.15s;font-size:14px}
    .action-item:hover{border-color:#7c3aed;background:#faf5ff;color:#6f3cff}
    .action-icon{width:38px;height:38px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
    .action-desc{font-size:11px;color:#9ca3af;font-weight:600;margin-top:2px}

    /* ── Recent Table ── */
    .table-wrap{overflow-x:auto;-webkit-overflow-scrolling:touch}
    table{width:100%;border-collapse:collapse;min-width:380px}
    thead{background:#f9fafb}
    th{font-size:10px;text-transform:uppercase;letter-spacing:.08em;color:#9ca3af;font-weight:950;padding:10px 12px;border-bottom:1px solid #f1f5f9;white-space:nowrap}
    td{padding:10px 12px;border-bottom:1px solid #f1f5f9;vertical-align:middle;font-size:13px}
    tr:last-child td{border-bottom:0}
    tr:hover td{background:#fafafe}

    /* ── Desktop ── */
    @media(min-width:993px){
      .content{padding:24px}
      .welcome{padding:28px 32px;border-radius:26px;margin-bottom:20px}
      .welcome h2{font-size:24px}
      .welcome p{font-size:14px;margin-bottom:20px}
      .stats-row{gap:16px;margin-bottom:20px}
      .stat-card{padding:20px 22px;border-radius:22px}
      .stat-value{font-size:28px}
      .stat-icon{width:46px;height:46px;border-radius:14px;margin-bottom:12px}
      .stat-label{font-size:11px;letter-spacing:.10em}
      .grid-bottom{grid-template-columns:1fr 1fr;gap:16px}
      .card{padding:20px;border-radius:22px}
      .hamburger{display:none}
      .usertext{display:block}
      th{font-size:11px;padding:12px 14px}
      td{padding:12px 14px}
    }
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
      <a class="active" href="<%=request.getContextPath()%>/patrol/dashboard">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M3 13h8V3H3v10zM13 21h8V11h-8v10zM13 3h8v6h-8V3zM3 21h8v-6H3v6z" stroke="currentColor" stroke-width="2"/></svg>
        Overview
      </a>
      <div class="menu-label">Summons</div>
      <a href="<%=request.getContextPath()%>/patrol/summons/create">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
        Create Summons
      </a>
      <a href="<%=request.getContextPath()%>/patrol/summons/history">
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

    <!-- Header -->
    <header class="header">
      <button class="hamburger d-lg-none" onclick="openSidebar()">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
          <path d="M4 6h16M4 12h16M4 18h16" stroke="currentColor" 
                stroke-width="2" stroke-linecap="round"/>
        </svg>
      </button>

      <div class="portal-title">PATROL Portal</div>

      <div class="header-right">
        <div class="userbox">
          <div class="usertext">
            <div style="font-weight:900;color:#111827;font-size:14px">
              <%= p.getPatrolName() %>
            </div>
            <div style="font-size:11px;color:#6b7280;font-weight:900;
                        letter-spacing:.10em;text-transform:uppercase">
              <%= p.getPatrolStaffId() %>
            </div>
          </div>
          <div class="avatar">
            <%= p.getPatrolName().substring(0,1).toUpperCase() %>
          </div>
        </div>
      </div>
    </header>

    <!-- Content -->
    <div class="content">

      <!-- Welcome Banner -->
      <div class="welcome">
        <h2>Hello, <%= p.getPatrolName() %>!</h2>
        <p>Ready to report a violation? Use the button below to create a new summons.</p>
        <a href="<%=request.getContextPath()%>/patrol/summons/create" 
           class="btn-white">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
            <path d="M12 5v14M5 12h14" stroke="currentColor" 
                  stroke-width="2.5" stroke-linecap="round"/>
          </svg>
          Create New Summons
        </a>

        <!-- Background Icon -->
        <div class="welcome-icon">
          <svg width="160" height="160" viewBox="0 0 24 24" fill="none">
            <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"
                  stroke="currentColor" stroke-width="2"/>
          </svg>
        </div>
      </div>

      <!-- Stats Row -->
      <div class="stats-row">
        <div class="stat-card">
          <div class="stat-icon icon-purple">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
              <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z"
                    stroke="currentColor" stroke-width="2"/>
              <path d="M14 2v6h6" stroke="currentColor" stroke-width="2"/>
            </svg>
          </div>
          <div class="stat-value"><%= totalReports %></div>
          <div class="stat-label">Total Reports</div>
        </div>

        <div class="stat-card">
          <div class="stat-icon icon-blue">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
              <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/>
              <path d="M12 6v6l4 2" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            </svg>
          </div>
          <div class="stat-value"><%= todayReports %></div>
          <div class="stat-label">Today's Reports</div>
        </div>

        <div class="stat-card">
          <div class="stat-icon icon-orange">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
              <path d="M12 9v4m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"
                    stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            </svg>
          </div>
          <div class="stat-value"><%= pendingReports %></div>
          <div class="stat-label">Pending Review</div>
        </div>
      </div>

      <!-- Bottom Grid -->
      <div class="grid-bottom">

        <!-- Quick Actions -->
        <section>
          <div class="card">
            <div class="card-title">Quick Actions</div>
            <div class="quick-actions">

              <a href="<%=request.getContextPath()%>/patrol/summons/create" 
                 class="action-item">
                <div class="action-icon icon-purple">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                    <path d="M12 5v14M5 12h14" stroke="currentColor" 
                          stroke-width="2.5" stroke-linecap="round"/>
                  </svg>
                </div>
                <div>
                  <div>Create New Summons</div>
                  <div class="action-desc">Report a vehicle or misconduct offense</div>
                </div>
              </a>

              <a href="<%=request.getContextPath()%>/patrol/summons/history" 
                 class="action-item">
                <div class="action-icon icon-blue">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                    <path d="M4 4h16v16H4V4z" stroke="currentColor" stroke-width="2"/>
                    <path d="M8 8h8M8 12h8M8 16h4" stroke="currentColor" 
                          stroke-width="2" stroke-linecap="round"/>
                  </svg>
                </div>
                <div>
                  <div>View Report History</div>
                  <div class="action-desc">See all summons you have submitted</div>
                </div>
              </a>

            </div>
          </div>
        </section>

        <!-- Recent Reports -->
        <section>
          <div class="card" style="padding:0;overflow:hidden">
            <div style="padding:20px 20px 0" class="card-title">
              Recent Reports
              <a href="<%=request.getContextPath()%>/patrol/summons/history" 
                 class="view-all">View All</a>
            </div>

            <div class="table-wrap" style="border:0;border-radius:0">
              <table>
                <thead>
                  <tr>
                    <th>Summons ID</th>
                    <th>Offense</th>
                    <th>Type</th>
                    <th>Amount</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  <% if (recentList != null && !recentList.isEmpty()) {
                       for (Summons s : recentList) {
                         String pillClass = "pill-unpaid";
                         if ("PAID".equals(s.getStatus()))     pillClass = "pill-paid";
                         if ("APPEALED".equals(s.getStatus())) pillClass = "pill-appealed";
                  %>
                  <tr>
                    <td style="font-weight:950;color:#111827;font-size:13px">
                      <%= s.getSummonsId() %>
                    </td>
                    <td style="font-size:12px;color:#6b7280;font-weight:600">
                      <%= s.getOffenseName() != null ? s.getOffenseName() : "-" %>
                    </td>
                    <td>
                      <span class="status-pill <%= "VEHICLE".equals(s.getSummonsType()) 
                        ? "pill-appealed" : "pill-unpaid" %>">
                        <%= s.getSummonsType() %>
                      </span>
                    </td>
                    <td style="font-weight:950;color:#111827">
                      RM <%= String.format("%.2f", s.getAmount()) %>
                    </td>
                    <td>
                      <span class="status-pill <%= pillClass %>">
                        <%= s.getStatus() %>
                      </span>
                    </td>
                  </tr>
                  <% } } else { %>
                  <tr>
                    <td colspan="5">
                      <div class="empty-state">
                        <svg width="40" height="40" viewBox="0 0 24 24" fill="none">
                          <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z"
                                stroke="currentColor" stroke-width="2"/>
                          <path d="M14 2v6h6" stroke="currentColor" stroke-width="2"/>
                        </svg>
                        <p>No reports yet. Create your first summons!</p>
                      </div>
                    </td>
                  </tr>
                  <% } %>
                </tbody>
              </table>
            </div>
          </div>
        </section>

      </div><!-- end grid-bottom -->

    </div><!-- end content -->
  </main>
</div><!-- end app -->

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
