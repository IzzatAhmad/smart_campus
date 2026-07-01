<%-- 
    Document   : dashboard
    Created on : 1 Jan 2026, 4:15:58 am
    Author     : SHAHRUL
--%>

<%-- 
    Document   : dashboard.jsp (Student)
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

  String roleLabel = "STUDENT Portal";

  // ── Real stats from servlet ──
  int totalSummons    = request.getAttribute("totalSummons")    != null ? (int) request.getAttribute("totalSummons")    : 0;
  int unpaidSummons   = request.getAttribute("unpaidSummons")   != null ? (int) request.getAttribute("unpaidSummons")   : 0;
  int paidSummons     = request.getAttribute("paidSummons")     != null ? (int) request.getAttribute("paidSummons")     : 0;
  int appealedSummons = request.getAttribute("appealedSummons") != null ? (int) request.getAttribute("appealedSummons") : 0;
  double outstanding  = request.getAttribute("outstanding")     != null ? (double) request.getAttribute("outstanding")  : 0.0;

  // ── Recent summons from servlet ──
  List<Summons> recentSummons = (List<Summons>) request.getAttribute("recentSummons");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Student Dashboard | Smart Campus</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

  <style>
    body{margin:0;background:#f5f6fb;font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif}
    .app{min-height:100vh;display:flex}

    /* Sidebar */
    .sidebar{
      width:260px;background:#f5f0ff;border-right:1px solid #e4d9f7;
      position:fixed;inset:0 auto 0 0;z-index:30;transform:translateX(0);
      transition:transform .25s ease;
      display:flex;flex-direction:column;
    }
    .sidebar.hidden{transform:translateX(-100%)}
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

    .sidebar-bottom{margin-top:auto;padding:14px;border-top:1px solid #e4d9f7}
    .logout-btn{
      width:100%;border:0;background:#f5f0ff;color:#dc2626;font-weight:900;
      padding:12px 14px;border-radius:12px;text-align:left;cursor:pointer;
    }
    .logout-btn:hover{background:#fef2f2}

    /* Overlay */
    .overlay{position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:20;display:none}
    .overlay.show{display:block}

    /* Main */
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

    /* Welcome Banner */
    .grid-top{display:grid;grid-template-columns:2fr 1fr;gap:16px}
    .welcome{
      background:linear-gradient(135deg,#6f3cff,#4338ca);
      border-radius:26px;padding:26px;color:#fff;position:relative;overflow:hidden;
      min-height:180px;
    }
    .welcome h2{margin:0 0 6px;font-weight:950}
    .welcome p{margin:0 0 18px;color:#e9d5ff;font-weight:600}
    .pay-btn{
      display:inline-flex;align-items:center;gap:10px;
      background:#fff;color:#6f3cff;font-weight:900;
      padding:10px 14px;border-radius:14px;border:0;
      text-decoration:none;cursor:pointer;
    }
    .pay-btn:hover{background:#faf5ff;color:#6f3cff}
    .welcome-icon{position:absolute;right:-20px;top:10px;opacity:.18}

    /* Outstanding Balance */
    .balance{
      background:#fff;border:1px solid #e5e7eb;border-radius:26px;
      padding:26px;display:flex;flex-direction:column;align-items:center;
      justify-content:center;text-align:center;
      box-shadow:0 6px 18px rgba(17,24,39,.04);
    }
    .balance-icon{
      width:62px;height:62px;border-radius:18px;background:#fef2f2;color:#dc2626;
      display:flex;align-items:center;justify-content:center;margin-bottom:12px;
    }
    .balance-amt{font-size:30px;font-weight:950;color:#111827}
    .balance-label{font-size:12px;font-weight:900;color:#6b7280;letter-spacing:.12em;text-transform:uppercase}

    /* Stats Row */
    .stats-row{
      display:grid;grid-template-columns:repeat(4,1fr);
      gap:14px;margin-top:16px;margin-bottom:16px;
    }
    .stat-card{
      background:#fff;border:1px solid #e5e7eb;border-radius:20px;
      padding:16px 18px;box-shadow:0 4px 12px rgba(17,24,39,.04);
      text-align:center;
    }
    .stat-value{font-size:26px;font-weight:950;color:#111827}
    .stat-label{font-size:11px;font-weight:900;color:#6b7280;
      text-transform:uppercase;letter-spacing:.10em;margin-top:4px}
    .stat-unpaid .stat-value{color:#ea580c}
    .stat-paid .stat-value{color:#16a34a}
    .stat-appealed .stat-value{color:#2563eb}
    .stat-total .stat-value{color:#6f3cff}

    /* Grid Bottom */
    .grid-bottom{display:grid;grid-template-columns:1fr 1fr;gap:16px}
    .section-title{display:flex;align-items:center;justify-content:space-between;margin-bottom:10px}
    .section-title h3{margin:0;font-size:18px;font-weight:950;color:#111827}
    .view-all{font-weight:900;color:#6f3cff;text-decoration:none;font-size:13px}
    .view-all:hover{color:#5b21b6}
    .icon-btn{width:38px;height:38px;border-radius:12px;border:0;background:#f3e8ff;color:#6f3cff;font-weight:900}
    .icon-btn:hover{background:#ede9fe}

    /* Card */
    .card{background:#fff;border:1px solid #e5e7eb;border-radius:26px;padding:16px;box-shadow:0 6px 18px rgba(17,24,39,.04)}

    /* Vehicle Item */
    .vehicle-item{display:flex;gap:14px;align-items:center;padding:14px;border-radius:18px;border:1px solid #f1f5f9;transition:.15s}
    .vehicle-item:hover{border-color:#e9d5ff}
    .veh-ico{width:48px;height:48px;border-radius:16px;background:#f3f4f6;color:#6b7280;display:flex;align-items:center;justify-content:center}
    .veh-main{flex:1}
    .veh-plate{font-weight:950;color:#111827}
    .veh-sub{font-size:13px;color:#6b7280;font-weight:700}
    .pill-approved{font-size:11px;font-weight:950;color:#16a34a;background:#f0fdf4;border:1px solid #dcfce7;padding:6px 10px;border-radius:999px}
    .pill-pending{font-size:11px;font-weight:950;color:#ea580c;background:#fff7ed;border:1px solid #ffedd5;padding:6px 10px;border-radius:999px}

    /* Table */
    .table-wrap{overflow:auto;border-radius:22px;border:1px solid #f1f5f9}
    table{width:100%;min-width:400px;border-collapse:collapse}
    thead{background:#f9fafb}
    th{font-size:11px;text-transform:uppercase;letter-spacing:.12em;color:#6b7280;font-weight:950;padding:14px;border-bottom:1px solid #f1f5f9}
    td{padding:14px;border-bottom:1px solid #f1f5f9;vertical-align:middle}
    tr:last-child td{border-bottom:0}
    tr:hover td{background:#fafafa}
    .sid{font-weight:950;color:#111827;font-size:13px}
    .sdesc{font-size:12px;color:#6b7280;font-weight:700}
    .status-pill{font-size:10px;font-weight:950;text-transform:uppercase;letter-spacing:.08em;padding:6px 10px;border-radius:999px;display:inline-block}
    .pill-unpaid{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}
    .pill-paid{background:#f0fdf4;color:#16a34a;border:1px solid #dcfce7}
    .pill-appealed{background:#eff6ff;color:#2563eb;border:1px solid #dbeafe}
    .pill-overdue{background:#fef2f2;color:#dc2626;border:1px solid #fee2e2}

    /* Alert banner */
    .alert-unpaid{
      background:#fff7ed;border:1px solid #ffedd5;border-radius:16px;
      padding:14px 18px;margin-bottom:16px;
      display:flex;align-items:center;gap:12px;
    }
    .alert-unpaid svg{color:#ea580c;flex-shrink:0}
    .alert-unpaid-text{font-weight:700;color:#ea580c;font-size:14px}

    /* Empty state */
    .empty-state{text-align:center;padding:32px;color:#9ca3af}
    .empty-state p{font-weight:700;font-size:14px;margin:8px 0 0}

    /* Responsive */
    @media (max-width: 992px){
      .main{margin-left:0;width:100%}
      .sidebar{transform:translateX(-100%)}
      .sidebar.show{transform:translateX(0)}
      .grid-top{grid-template-columns:1fr}
      .grid-bottom{grid-template-columns:1fr}
      .stats-row{grid-template-columns:repeat(2,1fr)}
      .usertext{display:block}
    }
    @media(max-width:576px){
      .stats-row{grid-template-columns:1fr 1fr}
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
      <a class="active" href="<%=request.getContextPath()%>/student/dashboard">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M3 13h8V3H3v10zM13 21h8V11h-8v10zM13 3h8v6h-8V3zM3 21h8v-6H3v6z" stroke="currentColor" stroke-width="2"/></svg>
        Overview
      </a>
      <div class="menu-label">My Records</div>
      <a href="<%=request.getContextPath()%>/student/vehicles">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M5 17H3v-5l2-5h14l2 5v5h-2" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><circle cx="7" cy="17" r="2" stroke="currentColor" stroke-width="2"/><circle cx="17" cy="17" r="2" stroke="currentColor" stroke-width="2"/></svg>
        My Vehicles
      </a>
      <a href="<%=request.getContextPath()%>/student/summons">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z" stroke="currentColor" stroke-width="2"/><path d="M14 2v6h6" stroke="currentColor" stroke-width="2"/></svg>
        My Summons
        <% if (unpaidSummons > 0) { %>
        <span style="margin-left:auto;background:#ef4444;color:#fff;font-size:10px;font-weight:950;padding:2px 8px;border-radius:999px"><%= unpaidSummons %></span>
        <% } %>
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

        <div class="portal-title"><%= roleLabel %></div>

        <div class="header-right">
          <% if (unpaidSummons > 0) { %>
          <button class="bell" type="button" title="You have unpaid summons">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
              <path d="M18 8a6 6 0 10-12 0c0 7-3 7-3 7h18s-3 0-3-7" stroke="currentColor" stroke-width="2" stroke-linejoin="round"/>
              <path d="M13.73 21a2 2 0 01-3.46 0" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            </svg>
            <span class="dot"></span>
          </button>
          <% } %>

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

        <!-- ── Alert banner if unpaid summons exist ── -->
        <% if (unpaidSummons > 0) { %>
        <div class="alert-unpaid">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
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

        <!-- ── Welcome + Outstanding ── -->
        <div class="grid-top">
          <div class="welcome">
            <h2>Hello, <%= s.getStudentName().split(" ")[0] %>!</h2>
            <% if (unpaidSummons > 0) { %>
            <p>You have <b><%= unpaidSummons %></b> unpaid summons. Please settle them promptly.</p>
            <% } else { %>
            <p>You have no unpaid summons. Keep up the good behavior!</p>
            <% } %>
            <a href="<%=request.getContextPath()%>/student/summons" class="pay-btn">
              View My Summons
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                <path d="M5 12h14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                <path d="M13 6l6 6-6 6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              </svg>
            </a>

            <div class="welcome-icon">
              <svg width="150" height="150" viewBox="0 0 24 24" fill="none">
                <path d="M2 7h20v10H2V7z" stroke="currentColor" stroke-width="2"/>
                <path d="M2 10h20" stroke="currentColor" stroke-width="2"/>
                <path d="M6 15h4" stroke="currentColor" stroke-width="2"/>
              </svg>
            </div>
          </div>

          <div class="balance">
            <div class="balance-icon">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none">
                <path d="M12 9v4" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                <path d="M12 17h.01" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                <path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"
                      stroke="currentColor" stroke-width="2" stroke-linejoin="round"/>
              </svg>
            </div>
            <div class="balance-amt">RM <%= String.format("%.2f", outstanding) %></div>
            <div class="balance-label">Outstanding Balance</div>
          </div>
        </div>

        <!-- ── Stats Row ── -->
        <div class="stats-row">
          <div class="stat-card stat-total">
            <div class="stat-value"><%= totalSummons %></div>
            <div class="stat-label">Total Summons</div>
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

        <!-- ── Bottom Grid ── -->
        <div class="grid-bottom">

          <!-- My Vehicles -->
          <section>
            <div class="section-title">
              <h3>My Registered Vehicles</h3>
              <a href="<%=request.getContextPath()%>/student/vehicles" class="view-all">View All</a>
            </div>

            <div class="card">
              <!-- Vehicles loaded from student vehicles page -->
              <div class="vehicle-item">
                <div class="veh-ico">
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <path d="M3 13l2-5h14l2 5" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                    <path d="M5 13h14v6H5v-6z" stroke="currentColor" stroke-width="2" stroke-linejoin="round"/>
                  </svg>
                </div>
                <div class="veh-main">
                  <div class="veh-plate">My Vehicles</div>
                  <div class="veh-sub">Click View All to manage vehicles</div>
                </div>
                <a href="<%=request.getContextPath()%>/student/vehicles" 
                   class="pill-approved" style="text-decoration:none">View</a>
              </div>
            </div>
          </section>

          <!-- Recent Summons -->
          <section>
            <div class="section-title">
              <h3>Recent Summons</h3>
              <a href="<%=request.getContextPath()%>/student/summons" class="view-all">View All</a>
            </div>

            <div class="card" style="padding:0">
              <div class="table-wrap">
                <table>
                  <thead>
                    <tr>
                      <th>Offense</th>
                      <th>Amount</th>
                      <th>Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    <% if (recentSummons != null && !recentSummons.isEmpty()) {
                         for (Summons sm : recentSummons) {
                           String pillClass = "pill-unpaid";
                           if ("PAID".equals(sm.getStatus()))     pillClass = "pill-paid";
                           if ("APPEALED".equals(sm.getStatus())) pillClass = "pill-appealed";
                           if ("OVERDUE".equals(sm.getStatus()))  pillClass = "pill-overdue";
                    %>
                    <tr>
                      <td>
                        <div class="sid"><%= sm.getSummonsId() %></div>
                        <div class="sdesc">
                          <%= sm.getOffenseName() != null ? sm.getOffenseName() : sm.getSummonsType() %>
                        </div>
                      </td>
                      <td style="font-weight:950;color:#111827">
                        RM <%= String.format("%.2f", sm.getAmount()) %>
                      </td>
                      <td>
                        <span class="status-pill <%= pillClass %>">
                          <%= sm.getStatus() %>
                        </span>
                      </td>
                    </tr>
                    <% } } else { %>
                    <tr>
                      <td colspan="3">
                        <div class="empty-state">
                          <svg width="36" height="36" viewBox="0 0 24 24" fill="none">
                            <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z"
                                  stroke="currentColor" stroke-width="2"/>
                            <path d="M14 2v6h6" stroke="currentColor" stroke-width="2"/>
                          </svg>
                          <p>No summons yet. Keep it up!</p>
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
