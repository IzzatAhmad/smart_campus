<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="model.ClericalStaff"%>
<%@page import="model.Vehicle"%>
<%
  ClericalStaff c = (ClericalStaff) session.getAttribute("clerical");
  if (c == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

  List<Vehicle> pendingList = (List<Vehicle>) request.getAttribute("pendingList");
  if (pendingList == null) pendingList = new java.util.ArrayList<>();

  String success = (String) session.getAttribute("success");
  String error   = (String) session.getAttribute("error");
  if (success != null) session.removeAttribute("success");
  if (error   != null) session.removeAttribute("error");
  String reqErr = (String) request.getAttribute("error");

  int pendingAppeals = 0; int pendingPayments = 0; int pendingVehicles = pendingList.size();
  try {
      pendingAppeals = new dao.AppealDAO().countPendingAppeals();
      try (java.sql.Connection _con = util.DBConnection.getConnection();
           java.sql.PreparedStatement _ps = _con.prepareStatement("SELECT COUNT(*) FROM payment WHERE status='PENDING_OFFICE'");
           java.sql.ResultSet _rs = _ps.executeQuery()) {
          if (_rs.next()) pendingPayments = _rs.getInt(1);
      }
  } catch (Exception _ex) {}
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Vehicle Approval | Smart Campus</title>
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
    .main{flex:1;min-width:0;margin-left:260px;display:flex;flex-direction:column}
    .header{height:64px;background:#fff;border-bottom:1px solid #e5e7eb;display:flex;align-items:center;justify-content:space-between;padding:0 16px;position:sticky;top:0;z-index:10}
    .hamburger{border:0;background:transparent;padding:8px;border-radius:10px}
    .hamburger:hover{background:#f3f4f6}
    .portal-title{font-weight:800;color:#111827}
    .header-right{display:flex;align-items:center;gap:14px}
    .userbox{display:flex;align-items:center;gap:12px;border-left:1px solid #f1f5f9;padding-left:14px}
    .usertext{display:none}
    .avatar{width:40px;height:40px;border-radius:999px;background:#ede9fe;color:#6f3cff;display:flex;align-items:center;justify-content:center;font-weight:900}
    .content{padding:24px 20px}

    /* ── Alerts ── */
    .alert-success{background:#f0fdf4;border:1px solid #bbf7d0;color:#15803d;border-radius:14px;padding:12px 16px;font-weight:700;margin-bottom:16px}
    .alert-error{background:#fef2f2;border:1px solid #fecaca;color:#dc2626;border-radius:14px;padding:12px 16px;font-weight:700;margin-bottom:16px}

    /* ── Page Header ── */
    .page-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:24px}
    .page-header h1{font-size:22px;font-weight:950;color:#111827;margin:0}
    .page-header p{font-size:13px;color:#6b7280;font-weight:700;margin:4px 0 0}
    .pending-count{background:#fff7ed;color:#ea580c;border:1.5px solid #ffedd5;font-size:13px;font-weight:950;padding:6px 16px;border-radius:999px}

    /* ── Vehicle Request Card ── */
    .request-card{
      background:#fff;border:1px solid #e5e7eb;border-radius:24px;
      box-shadow:0 4px 16px rgba(17,24,39,.06);
      margin-bottom:20px;overflow:hidden;
      transition:.15s;
    }
    .request-card:hover{border-color:#d8b4fe;box-shadow:0 8px 24px rgba(124,58,237,.10)}

    /* Card Header band */
    .card-header-band{
      background:linear-gradient(135deg,#7c3aed,#6f3cff);
      padding:16px 24px;
      display:flex;align-items:center;justify-content:space-between;
    }
    .plate-number{
      font-size:22px;font-weight:950;color:#fff;
      letter-spacing:.06em;
    }
    .vehicle-type-badge{
      background:rgba(255,255,255,.2);color:#fff;
      font-size:12px;font-weight:900;padding:5px 14px;
      border-radius:999px;letter-spacing:.06em;text-transform:uppercase;
      display:flex;align-items:center;gap:6px;
    }
    .pending-badge{
      background:#fff7ed;color:#ea580c;border:1.5px solid #ffedd5;
      font-size:11px;font-weight:950;padding:4px 12px;border-radius:999px;
      text-transform:uppercase;letter-spacing:.06em;
    }

    /* Card Body */
    .card-body-grid{
      display:grid;
      grid-template-columns:1fr 1fr 200px;
      gap:0;
    }

    /* Info Section */
    .info-section{padding:20px 24px;border-right:1px solid #f1f5f9}
    .info-section-title{
      font-size:10px;font-weight:900;text-transform:uppercase;letter-spacing:.12em;
      color:#a78bfa;margin-bottom:12px;
    }
    .info-row{display:flex;align-items:center;gap:10px;margin-bottom:10px}
    .info-icon{
      width:32px;height:32px;border-radius:10px;background:#f5f0ff;color:#7c3aed;
      display:flex;align-items:center;justify-content:center;flex-shrink:0;
    }
    .info-label{font-size:10px;font-weight:900;color:#9ca3af;text-transform:uppercase;letter-spacing:.06em}
    .info-value{font-size:13px;font-weight:800;color:#111827;margin-top:1px}

    /* Grant Section */
    .grant-section{
      padding:20px 24px;
      display:flex;flex-direction:column;align-items:center;justify-content:center;
      border-right:1px solid #f1f5f9;gap:12px;
    }
    .grant-img{
      width:100%;max-width:160px;height:120px;
      border-radius:16px;border:2px solid #e4d9f7;
      object-fit:cover;cursor:pointer;
      transition:.15s;
      display:block;
    }
    .grant-img:hover{border-color:#7c3aed;transform:scale(1.02)}
    .btn-view-grant{
      background:#f5f0ff;color:#7c3aed;border:1.5px solid #e4d9f7;
      font-size:12px;font-weight:900;padding:7px 16px;
      border-radius:10px;cursor:pointer;border:0;
      display:inline-flex;align-items:center;gap:6px;
      transition:.15s;
    }
    .btn-view-grant:hover{background:#ede9fe}

    /* Action Section */
    .action-section{
      padding:20px 24px;
      display:flex;flex-direction:column;justify-content:center;gap:12px;
    }
    .action-title{
      font-size:10px;font-weight:900;text-transform:uppercase;letter-spacing:.12em;
      color:#9ca3af;margin-bottom:4px;
    }
    .comment-input{
      width:100%;border:1.5px solid #e5e7eb;border-radius:12px;
      padding:9px 14px;font-weight:600;color:#111827;
      background:#f9fafb;font-size:13px;outline:none;
      box-sizing:border-box;transition:.15s;resize:none;
    }
    .comment-input:focus{border-color:#7c3aed;background:#fff;box-shadow:0 0 0 3px rgba(124,58,237,.08)}
    .action-buttons{display:flex;flex-direction:column;gap:8px}
    .btn-approve{
      width:100%;border:0;background:#16a34a;color:#fff;
      font-weight:950;padding:11px 14px;border-radius:12px;
      display:flex;align-items:center;justify-content:center;gap:8px;
      cursor:pointer;font-size:13px;transition:.15s;
    }
    .btn-approve:hover{background:#15803d}
    .btn-reject{
      width:100%;border:0;background:#fef2f2;color:#dc2626;
      border:1.5px solid #fecaca;
      font-weight:950;padding:10px 14px;border-radius:12px;
      display:flex;align-items:center;justify-content:center;gap:8px;
      cursor:pointer;font-size:13px;transition:.15s;
    }
    .btn-reject:hover{background:#fee2e2}

    /* ── Empty State ── */
    .empty-wrap{
      background:#fff;border:2px dashed #e4d9f7;border-radius:24px;
      padding:60px 20px;text-align:center;
    }
    .empty-icon{
      width:72px;height:72px;background:#f5f0ff;border-radius:999px;
      display:flex;align-items:center;justify-content:center;
      margin:0 auto 16px;color:#a78bfa;
    }
    .empty-title{font-size:18px;font-weight:950;color:#111827;margin-bottom:6px}
    .empty-sub{font-size:14px;font-weight:600;color:#6b7280}

    /* ── Responsive ── */
    @media(max-width:992px){
      .main{margin-left:0}
      .sidebar{transform:translateX(-100%)}
      .sidebar.show{transform:translateX(0)}
      .usertext{display:block}
      .card-body-grid{grid-template-columns:1fr}
      .info-section,.grant-section{border-right:0;border-bottom:1px solid #f1f5f9}
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
      <a href="<%=request.getContextPath()%>/clerical/dashboard">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M3 13h8V3H3v10zM13 21h8V11h-8v10zM13 3h8v6h-8V3zM3 21h8v-6H3v6z" stroke="currentColor" stroke-width="2"/></svg>
        Overview
      </a>
      <div class="menu-label">Management</div>
      <a class="active" href="<%=request.getContextPath()%>/clerical/vehicle/requests">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M5 17H3v-5l2-5h14l2 5v5h-2" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><circle cx="7" cy="17" r="2" stroke="currentColor" stroke-width="2"/><circle cx="17" cy="17" r="2" stroke="currentColor" stroke-width="2"/></svg>
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

      <% if (success != null) { %><div class="alert-success">✓ <%= success %></div><% } %>
      <% if (error != null) { %><div class="alert-error">✕ <%= error %></div><% } %>
      <% if (reqErr != null) { %><div class="alert-error">✕ <%= reqErr %></div><% } %>

      <!-- ── Page Header ── -->
      <div class="page-header">
        <div>
          <h1>Vehicle Approval Requests</h1>
          <p>Review student vehicle registrations and approve or reject each one.</p>
        </div>
        <% if (pendingList.size() > 0) { %>
        <span class="pending-count">
          <%= pendingList.size() %> Pending Request<%= pendingList.size() != 1 ? "s" : "" %>
        </span>
        <% } %>
      </div>

      <!-- ── Empty State ── -->
      <% if (pendingList.isEmpty()) { %>
      <div class="empty-wrap">
        <div class="empty-icon">
          <svg width="36" height="36" viewBox="0 0 24 24" fill="none">
            <path d="M5 17H3v-5l2-5h14l2 5v5h-2" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            <circle cx="7" cy="17" r="2" stroke="currentColor" stroke-width="2"/>
            <circle cx="17" cy="17" r="2" stroke="currentColor" stroke-width="2"/>
            <path d="M20 6L9 17l-5-5" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/>
          </svg>
        </div>
        <div class="empty-title">All Caught Up!</div>
        <div class="empty-sub">No pending vehicle registration requests at this time.</div>
      </div>

      <% } else {
          for (Vehicle v : pendingList) {
            String imgUrl = request.getContextPath() + "/grant/image?file=" + new java.io.File(v.getGrantImagePath()).getName();
            if (v.getGrantImagePath() == null || v.getGrantImagePath().isBlank()) {
              imgUrl = "https://via.placeholder.com/160x120?text=Grant";
            }
            boolean isCar = "CAR".equalsIgnoreCase(v.getVehicleType());
            String studentName = v.getStudentName() != null ? v.getStudentName() : "N/A";
            String matricNo    = v.getMatricNo()    != null ? v.getMatricNo()    : "N/A";
      %>

      <!-- ── Request Card ── -->
      <div class="request-card">

        <!-- Header Band -->
        <div class="card-header-band">
          <div style="display:flex;align-items:center;gap:14px">
            <div>
              <div class="plate-number"><%= v.getPlateNumber() %></div>
              <div style="font-size:12px;color:rgba(255,255,255,.75);font-weight:700;margin-top:2px">
                <%= v.getVehicleId() %>
              </div>
            </div>
          </div>
          <div style="display:flex;align-items:center;gap:10px">
            <div class="vehicle-type-badge">
              <% if (isCar) { %>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M5 17H3v-5l2-5h14l2 5v5h-2" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><circle cx="7" cy="17" r="2" stroke="currentColor" stroke-width="2"/><circle cx="17" cy="17" r="2" stroke="currentColor" stroke-width="2"/></svg>
              Car
              <% } else { %>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="12" r="3" stroke="currentColor" stroke-width="2"/></svg>
              Motorcycle
              <% } %>
            </div>
            <span class="pending-badge">Pending</span>
          </div>
        </div>

        <!-- Body -->
        <div class="card-body-grid">

          <!-- Vehicle + Student Info -->
          <div class="info-section">
            <div class="info-section-title">Vehicle Details</div>

            <div class="info-row">
              <div class="info-icon">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
              </div>
              <div>
                <div class="info-label">Brand</div>
                <div class="info-value"><%= v.getBrand() %></div>
              </div>
            </div>

            <div class="info-row">
              <div class="info-icon">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="12" r="4" fill="currentColor"/></svg>
              </div>
              <div>
                <div class="info-label">Color</div>
                <div class="info-value"><%= v.getColor() %></div>
              </div>
            </div>

            <div class="info-row">
              <div class="info-icon">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><rect x="2" y="7" width="20" height="14" rx="2" stroke="currentColor" stroke-width="2"/><path d="M16 7V5a2 2 0 00-2-2h-4a2 2 0 00-2 2v2" stroke="currentColor" stroke-width="2"/></svg>
              </div>
              <div>
                <div class="info-label">Engine CC</div>
                <div class="info-value"><%= v.getEngineCC() %></div>
              </div>
            </div>

            <div style="height:1px;background:#f1f5f9;margin:14px 0"></div>
            <div class="info-section-title">Student Information</div>

            <div class="info-row">
              <div class="info-icon" style="background:#eff6ff;color:#2563eb">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="7" r="4" stroke="currentColor" stroke-width="2"/></svg>
              </div>
              <div>
                <div class="info-label">Student Name</div>
                <div class="info-value"><%= studentName %></div>
              </div>
            </div>

            <div class="info-row">
              <div class="info-icon" style="background:#eff6ff;color:#2563eb">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><rect x="3" y="4" width="18" height="16" rx="2" stroke="currentColor" stroke-width="2"/><path d="M8 9h8M8 13h5" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
              </div>
              <div>
                <div class="info-label">Matric No</div>
                <div class="info-value"><%= matricNo %></div>
              </div>
            </div>

            <div class="info-row">
              <div class="info-icon" style="background:#eff6ff;color:#2563eb">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M4 4h16v16H4V4z" stroke="currentColor" stroke-width="2"/><path d="M4 9h16" stroke="currentColor" stroke-width="2"/></svg>
              </div>
              <div>
                <div class="info-label">Student ID</div>
                <div class="info-value" style="font-size:12px"><%= v.getStudentId() %></div>
              </div>
            </div>
          </div>

          <!-- Grant Image -->
          <div class="grant-section">
            <div style="font-size:10px;font-weight:900;text-transform:uppercase;letter-spacing:.12em;color:#a78bfa;margin-bottom:8px">Grant Image</div>
            <img class="grant-img" src="<%= imgUrl %>" alt="Grant Image"
                 onclick="openModal('<%= imgUrl %>', '<%= v.getPlateNumber() %>')">
            <button class="btn-view-grant" type="button"
                    onclick="openModal('<%= imgUrl %>', '<%= v.getPlateNumber() %>')">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="12" r="3" stroke="currentColor" stroke-width="2"/></svg>
              View Full Image
            </button>
          </div>

          <!-- Action Section -->
          <div class="action-section">
            <form method="post" action="<%=request.getContextPath()%>/clerical/vehicle/decide">
              <input type="hidden" name="vehicleId" value="<%= v.getVehicleId() %>">

              <div class="action-title">Clerical Decision</div>

              <textarea class="comment-input" name="comment" rows="3"
                        placeholder="Optional comment to student (e.g. reason for rejection)..."></textarea>

              <div class="action-buttons">
                <button type="submit" name="action" value="APPROVED" class="btn-approve">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                    <path d="M20 6L9 17l-5-5" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/>
                  </svg>
                  Approve Registration
                </button>
                <button type="submit" name="action" value="REJECTED" class="btn-reject"
                        onclick="return confirm('Reject the vehicle registration for <%= v.getPlateNumber() %>?')">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                    <path d="M18 6L6 18M6 6l12 12" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/>
                  </svg>
                  Reject Registration
                </button>
              </div>
            </form>
          </div>

        </div><!-- end card-body-grid -->
      </div><!-- end request-card -->

      <% } } %>

    </div><!-- end content -->
  </main>
</div>

<!-- ── Grant Image Modal ── -->
<div class="modal fade" id="grantModal" tabindex="-1">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content" style="border-radius:22px;border:0;overflow:hidden">
      <div class="modal-header" style="background:linear-gradient(135deg,#7c3aed,#6f3cff);border:0;padding:16px 24px">
        <h5 class="modal-title" style="color:#fff;font-weight:950;font-size:16px" id="modalTitle">
          Grant Image Preview
        </h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body text-center" style="padding:24px;background:#f9fafb">
        <img id="modalImg" src="" alt="Grant"
             style="max-width:100%;border-radius:16px;border:2px solid #e4d9f7;box-shadow:0 8px 24px rgba(0,0,0,.12)">
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  function openModal(url, plate) {
    document.getElementById("modalImg").src = url;
    document.getElementById("modalTitle").textContent =
      "Grant Image — " + (plate || "");
    new bootstrap.Modal(document.getElementById("grantModal")).show();
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
