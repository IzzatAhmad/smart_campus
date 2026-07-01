<%-- 
    Document   : vehicle_details.jsp
    Created on : 20 Jan 2026, 7:11:38 pm
    Author     : SHAHRUL
--%>

<%-- 
    Document   : vehicle_details
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Student"%>
<%@page import="model.Vehicle"%>
<%
  Student s = (Student) session.getAttribute("student");
  if (s == null) { response.sendRedirect(request.getContextPath()+"/login"); return; }

  Vehicle v = (Vehicle) request.getAttribute("vehicle");
  if (v == null) { response.sendRedirect(request.getContextPath()+"/student/vehicles"); return; }

  String fileName = (v.getGrantImagePath() == null) ? "" : new java.io.File(v.getGrantImagePath()).getName();
  String imgUrl = request.getContextPath() + "/grant/image?file=" + fileName;

  String status = (v.getStatus() == null) ? "PENDING" : v.getStatus().toUpperCase();
  String pillClass = "pill-pending";
  if ("APPROVED".equals(status)) pillClass = "pill-approved";
  if ("REJECTED".equals(status)) pillClass = "pill-rejected";

    int unpaidCount = 0;
    try {
        dao.SummonsDAO _sd = new dao.SummonsDAO();
        unpaidCount = _sd.countByStatusForStudent(s.getMatricNo(), s.getStudentId(), "UNPAID");
    } catch (Exception _e) {}
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Vehicle Details | Smart Campus</title>
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
      .usertext{display:block}
    }

    /* ── Page Head ── */
    .page-head{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:14px}
    .page-title{margin:0;font-weight:950;color:#111827}
    .muted{color:#6b7280;font-weight:700}
    .content{padding:18px 16px 26px;max-width:1100px}
    .imgbox{border:1px solid #eef0f6;border-radius:22px;overflow:hidden;background:#f9fafb}
    .imgbox img{width:100%;height:360px;object-fit:cover;display:block}
    .pill{font-size:10px;font-weight:950;letter-spacing:.08em;text-transform:uppercase;padding:6px 10px;border-radius:999px;display:inline-block;border:1px solid transparent}
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
      <a href="<%=request.getContextPath()%>/student/dashboard">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M3 13h8V3H3v10zM13 21h8V11h-8v10zM13 3h8v6h-8V3zM3 21h8v-6H3v6z" stroke="currentColor" stroke-width="2"/></svg>
        Overview
      </a>
      <div class="menu-label">My Records</div>
      <a class="active" href="<%=request.getContextPath()%>/student/vehicles">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M5 17H3v-5l2-5h14l2 5v5h-2" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><circle cx="7" cy="17" r="2" stroke="currentColor" stroke-width="2"/><circle cx="17" cy="17" r="2" stroke="currentColor" stroke-width="2"/></svg>
        My Vehicles
      </a>
      <a href="<%=request.getContextPath()%>/student/summons">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z" stroke="currentColor" stroke-width="2"/><path d="M14 2v6h6" stroke="currentColor" stroke-width="2"/></svg>
        My Summons
        <% if (unpaidCount > 0) { %><span class="notif-badge"><%= unpaidCount %></span><% } %>
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
        <div class="page-head">
          <div>
            <h2 class="page-title">Vehicle Details</h2>
            <div class="muted"><%= v.getPlateNumber() %> • <span class="pill <%= pillClass %>"><%= status %></span></div>
          </div>
          <a class="btn-soft" href="<%=request.getContextPath()%>/student/vehicles">Back</a>
        </div>

        <div class="cardx">
          <div class="row g-3">
            <div class="col-lg-7">
              <div class="imgbox">
                <img src="<%= imgUrl %>" alt="Grant Image">
              </div>
            </div>

            <div class="col-lg-5">
              <div class="mb-2 muted">Information</div>
              <div class="cardx" style="padding:14px;border-radius:22px;box-shadow:none">
                <div class="mb-2"><b>Vehicle ID:</b> <%= v.getVehicleId() %></div>
                <div class="mb-2"><b>Type:</b> <%= v.getVehicleType() %></div>
                <div class="mb-2"><b>Brand:</b> <%= v.getBrand() %></div>
                <div class="mb-2"><b>Color:</b> <%= v.getColor() %></div>
                <div class="mb-2"><b>Engine CC:</b> <%= v.getEngineCC() %></div>
                <div class="mb-2"><b>Status:</b> <span class="pill <%= pillClass %>"><%= status %></span></div>

                <% if (v.getClerkComment() != null && !v.getClerkComment().isBlank()) { %>
                  <div class="mt-3 p-3" style="background:#f9fafb;border:1px solid #eef0f6;border-radius:16px">
                    <div class="muted" style="font-weight:900;margin-bottom:6px">Clerical Comment</div>
                    <div style="font-weight:700;color:#111827"><%= v.getClerkComment() %></div>
                  </div>
                <% } %>

                <div class="mt-3 d-flex gap-2">
                  <a class="btn-soft" href="<%=request.getContextPath()%>/student/vehicle/edit?id=<%= v.getVehicleId() %>">Edit</a>
                </div>
              </div>
            </div>
          </div>
        </div>

      </div>
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
