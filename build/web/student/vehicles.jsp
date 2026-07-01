<%-- 
    Document   : vehicles
    Created on : 20 Jan 2026, 4:09:23 pm
    Author     : SHAHRUL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="model.Student"%>
<%@page import="model.Vehicle"%>
<%@page import="dao.VehicleDAO"%>

<%
  Student s = (Student) session.getAttribute("student");
  if (s == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
  }

  List<Vehicle> vehicleList = (List<Vehicle>) request.getAttribute("vehicleList");
  if (vehicleList == null) vehicleList = new ArrayList<>();

  String success = (String) request.getAttribute("success");
  String error   = (String) request.getAttribute("error");

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
  <title>My Vehicles | Smart Campus</title>
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
    
    /* PENAMBAHBAIKAN HEADER: Supaya teks nama panjang tidak melimpah */
    .header{
      min-height:64px;background:#fff;border-bottom:1px solid #e5e7eb;
      display:flex;align-items:center;justify-content:space-between;
      padding:10px 16px;position:sticky;top:0;z-index:10;
    }
    .hamburger{border:0;background:transparent;padding:8px;border-radius:10px;flex-shrink:0;}
    .hamburger:hover{background:#f3f4f6}
    .portal-title{font-weight:800;color:#111827;margin-right:10px;}
    .header-right{display:flex;align-items:center;gap:14px;min-width:0;}
    .userbox{display:flex;align-items:center;gap:12px;border-left:1px solid #f1f5f9;padding-left:14px;min-width:0;}
    .usertext{text-align:right;}
    .avatar{width:40px;height:40px;border-radius:999px;background:#ede9fe;color:#6f3cff;display:flex;align-items:center;justify-content:center;font-weight:900;flex-shrink:0;}

    .content{padding:18px 16px 26px}

    /* ── Shared Pills ── */
    .status-pill{font-size:10px;font-weight:950;text-transform:uppercase;letter-spacing:.08em;padding:5px 10px;border-radius:999px;display:inline-block}
    .pill-unpaid{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}
    .pill-paid{background:#f0fdf4;color:#16a34a;border:1px solid #dcfce7}
    .pill-pending{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}
    .pill-approved{background:#f0fdf4;color:#16a34a;border:1px solid #dcfce7}
    .pill-rejected{background:#fef2f2;color:#dc2626;border:1px solid #fee2e2}

    /* ── Page Head ── */
    .page-head{display:flex;align-items:center;justify-content:space-between;gap:16px;margin-bottom:20px}
    .page-title{margin:0;font-weight:950;color:#111827;font-size:24px;}
    .muted{color:#6b7280;font-weight:600;font-size:13px;}
    .btn-purple{background:#6f3cff;border:0;color:#fff;font-weight:900;border-radius:14px;padding:10px 16px;box-shadow:0 12px 26px rgba(111,60,255,.18);text-decoration:none;display:inline-flex;align-items:center;gap:8px;flex-shrink:0;}
    .btn-purple:hover{background:#5f2df0;color:#fff}

    /* ── Vehicle Cards Grid (DIBAIKI) ── */
    .grid{display:grid;grid-template-columns:repeat(3,1fr);gap:16px}
    .veh-card{background:#fff;border:1px solid #e5e7eb;border-radius:22px;box-shadow:0 6px 18px rgba(17,24,39,.04);overflow:hidden;display:flex;flex-direction:column;justify-content:between;}
    .veh-top{padding:16px 16px 10px}
    .veh-plate{font-weight:950;color:#111827;font-size:18px}
    .veh-sub{font-size:12px;color:#6b7280;font-weight:800;margin-top:2px}
    
    /* Fleksibel untuk kandungan tengah kad */
    .veh-body{display:flex;gap:16px;padding:0 16px 16px;align-items:center}
    .veh-img{width:100px;height:76px;border-radius:14px;border:1px solid #eef0f6;background:#f9fafb;object-fit:cover;flex-shrink:0;}
    .veh-meta{flex:1;min-width:0;}
    .meta-row{font-size:12px;color:#374151;font-weight:800;margin-bottom:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
    .meta-row span{color:#6b7280;font-weight:900}
    
    /* Bahagian butang bawah kad */
    .veh-foot{border-top:1px solid #f1f5f9;padding:14px 16px;display:flex;align-items:center;justify-content:space-between;background:#fff;gap:10px;flex-wrap:wrap;}
    .pill{font-size:10px;font-weight:950;letter-spacing:.08em;text-transform:uppercase;padding:6px 12px;border-radius:999px;display:inline-block;border:1px solid transparent}
    .small-btn{border:0;background:#f3e8ff;color:#6f3cff;font-weight:950;padding:8px 12px;border-radius:12px;font-size:12px;text-decoration:none;text-align:center;}
    .small-btn:hover{background:#ede9fe;color:#6f3cff}
    
    .empty{background:#fff;border:2px dashed #e5e7eb;border-radius:22px;padding:40px;text-align:center;color:#9ca3af;font-weight:900}

    /* ── Responsive breakpoints (DIBAIKI) ── */
    @media(max-width:1100px){
      .grid{grid-template-columns:repeat(2,1fr)}
    }

    @media(max-width:992px){
      .main{margin-left:0;width:100%}
      .sidebar{transform:translateX(-100%)}
      .sidebar.show{transform:translateX(0)}
    }

    /* SANGAT PENTING: Pengoptimuman Khas untuk Skrin Telefon Pintar (Mobile) */
    @media(max-width:768px){
      .usertext{display:none;} /* Sorok nama panjang dalam header, kekalkan avatar sahaja di mobile */
      .page-head{flex-direction:column; align-items:stretch; gap:14px;}
      .btn-purple{justify-content:center;}
      
      /* Mengubah kad menjadi 1 baris untuk 1 kad sepenuhnya */
      .grid{grid-template-columns:1fr;}
      
      /* Berikan ruang ekstra supaya gambar geran tidak terlalu tersepit */
      .veh-img{width:110px; height:82px;}
      
      /* Membenarkan susunan butang turun ke bawah secara kemas jika skrin terlampau sempit */
      .veh-foot{
        flex-direction:row;
        justify-content:space-between;
      }
    }

    @media(max-width:400px){
      .veh-body{flex-direction:column; align-items:start; gap:12px;}
      .veh-img{width:100%; height:120px;}
      .veh-foot { flex-direction: column; align-items: stretch; gap: 8px; }
      .veh-foot .pill { text-align: center; }
      .veh-foot div { display: flex; flex-direction: column; gap: 6px; }
    }
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
            <div class="usertext d-none d-md-block">
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
            <h2 class="page-title">My Vehicles</h2>
            <div class="muted">Register your vehicle and wait for clerical approval.</div>
          </div>

          <a class="btn-purple" href="<%=request.getContextPath()%>/student/vehicle/register">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
              <path d="M12 5v14M5 12h14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            </svg>
            Register Vehicle
          </a>
        </div>

        <% if (success != null) { %>
          <div class="alert alert-success rounded-4"><%= success %></div>
        <% } %>
        <% if (error != null) { %>
          <div class="alert alert-danger rounded-4"><%= error %></div>
        <% } %>

        <% if (vehicleList.isEmpty()) { %>
          <div class="empty">
            No vehicles registered yet.<br>
            Click <span style="color:#6f3cff">Register Vehicle</span> to add one.
          </div>
        <% } else { %>

          <div class="grid">
            <% for (Vehicle v : vehicleList) { 
                 String status = (v.getStatus() == null) ? "PENDING" : v.getStatus().toUpperCase();

                 String pillClass = "pill-pending";
                 if ("APPROVED".equals(status)) pillClass = "pill-approved";
                 if ("REJECTED".equals(status)) pillClass = "pill-rejected";

                 String imgUrl = request.getContextPath() + "/grant/image?file=" + new java.io.File(v.getGrantImagePath()).getName();
                 if (v.getGrantImagePath() == null || v.getGrantImagePath().isBlank()) {
                   imgUrl = "https://via.placeholder.com/160x120?text=Grant";
                 }

                 boolean canDelete = false;
                 try {
                     canDelete = !new dao.VehicleDAO().hasSummons(v.getVehicleId());
                 } catch (Exception _e) {}
            %>

              <div class="veh-card">
                <div class="veh-top">
                  <div class="veh-plate"><%= v.getPlateNumber() %></div>
                  <div class="veh-sub"><%= v.getVehicleType() %> • <%= v.getBrand() %> • <%= v.getColor() %></div>
                </div>

                <div class="veh-body">
                  <img class="veh-img" src="<%= imgUrl %>" alt="Grant Image">
                  <div class="veh-meta">
                    <div class="meta-row">Vehicle ID: <span><%= v.getVehicleId() %></span></div>
                    <div class="meta-row">Engine CC: <span><%= v.getEngineCC() %></span></div>
                    <div class="meta-row">Status: <span><%= status %></span></div>
                  </div>
                </div>

                <div class="veh-foot">
                    <span class="pill <%= pillClass %>"><%= status %></span>

                    <div style="display:flex; gap:6px; flex-wrap:wrap;">
                      <a class="small-btn" href="<%=request.getContextPath()%>/student/vehicle/details?id=<%= v.getVehicleId() %>">
                        Details
                      </a>

                      <% if ("APPROVED".equals(status)) { %>
                      <a class="small-btn" href="<%=request.getContextPath()%>/student/vehicle/edit?id=<%= v.getVehicleId() %>">
                        Edit
                      </a>
                      <% } else { %>
                      <span title="<%= "PENDING".equals(status) ? "Vehicle is awaiting clerical approval" : "Rejected vehicles cannot be edited" %>"
                            style="font-size:11px;font-weight:900;color:#9ca3af;padding:8px 10px; display:inline-block;cursor:not-allowed">
                        <%= "PENDING".equals(status) ? "Pending 🕐" : "Rejected 🔒" %>
                      </span>
                      <% } %>

                      <% if (canDelete) { %>
                      <form method="post" action="<%=request.getContextPath()%>/student/vehicle/delete"
                            onsubmit="return confirm('Delete this vehicle? This cannot be undone.');" style="margin:0; display:inline;">
                        <input type="hidden" name="id" value="<%= v.getVehicleId() %>">
                        <button type="submit" class="small-btn" style="background:#fef2f2;color:#dc2626;">
                          Delete
                        </button>
                      </form>
                      <% } else { %>
                      <span title="Cannot delete — this vehicle has summons records"
                            style="font-size:11px;font-weight:900;color:#9ca3af;padding:8px 10px; display:inline-block;cursor:not-allowed">
                        Locked 🔒
                      </span>
                      <% } %>
                    </div>
                  </div>
              </div>

            <% } %>
          </div>

        <% } %>

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