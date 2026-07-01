<%-- 
    Document   : create_summons.jsp (Patrol Staff)
    Author     : SHAHRUL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.PatrolStaff"%>
<%@page import="model.OffenseType"%>
<%@page import="java.util.List"%>
<%
    PatrolStaff p = (PatrolStaff) session.getAttribute("patrol");
    if (p == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<OffenseType> offenseList = (List<OffenseType>) request.getAttribute("offenseList");

    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg   = (String) session.getAttribute("errorMsg");
    session.removeAttribute("successMsg");
    session.removeAttribute("errorMsg");

    String currentPage = request.getRequestURI();

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
  <title>Create Summons | Smart Campus</title>
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

    /* ── Content constraint ── */
    .content{padding:24px 20px;max-width:800px}

    /* ── Type Toggle ── */
    .type-toggle{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:24px}
    .type-btn{border:2px solid #e5e7eb;background:#fff;border-radius:18px;padding:16px;cursor:pointer;text-align:center;transition:.15s}
    .type-btn:hover{border-color:#6f3cff;background:#faf5ff}
    .type-btn.selected{border-color:#6f3cff;background:#f3e8ff}
    .type-btn .type-icon{width:44px;height:44px;border-radius:14px;display:flex;align-items:center;justify-content:center;margin:0 auto 10px}
    .icon-vehicle{background:#eff6ff;color:#2563eb}
    .icon-misconduct{background:#fff7ed;color:#ea580c}
    .type-btn.selected .icon-vehicle{background:#dbeafe}
    .type-btn.selected .icon-misconduct{background:#ffedd5}
    .type-label{font-weight:950;color:#111827;font-size:15px}
    .type-desc{font-size:12px;color:#6b7280;font-weight:600;margin-top:4px}

    /* ── Form Card ── */
    .form-card{background:#fff;border:1px solid #e5e7eb;border-radius:22px;padding:24px;box-shadow:0 4px 12px rgba(17,24,39,.04);margin-bottom:16px}
    .form-card-title{font-size:15px;font-weight:950;color:#111827;margin-bottom:18px;display:flex;align-items:center;gap:8px}
    .form-label-custom{font-size:12px;font-weight:900;color:#374151;text-transform:uppercase;letter-spacing:.08em;margin-bottom:6px;display:block}
    .form-input-custom{width:100%;border:1.5px solid #e5e7eb;border-radius:12px;padding:11px 14px;font-weight:700;color:#111827;background:#f9fafb;font-size:14px;outline:none;box-sizing:border-box;transition:.15s}
    .form-input-custom:focus{border-color:#6f3cff;background:#fff;box-shadow:0 0 0 3px rgba(111,60,255,.08)}
    .form-group{margin-bottom:16px}
    .field-note{font-size:11px;color:#9ca3af;font-weight:600;margin-top:4px}

    /* ── Amount Display ── */
    .amount-display{background:#f3e8ff;border:1.5px solid #e9d5ff;border-radius:12px;padding:11px 14px;font-weight:950;color:#6f3cff;font-size:18px}

    /* ── Upload Area ── */
    .upload-area{border:2px dashed #e5e7eb;border-radius:16px;padding:24px;text-align:center;cursor:pointer;transition:.15s;background:#f9fafb}
    .upload-area:hover{border-color:#6f3cff;background:#faf5ff}
    .upload-area.has-file{border-color:#16a34a;background:#f0fdf4}
    .upload-icon{color:#9ca3af;margin-bottom:8px}
    .upload-text{font-weight:700;color:#6b7280;font-size:14px}
    .upload-sub{font-size:12px;color:#9ca3af;font-weight:600;margin-top:4px}
    .preview-img{max-width:100%;max-height:200px;border-radius:12px;margin-top:12px;display:none}

    /* ── Submit Button ── */
    .btn-submit{width:100%;background:#6f3cff;color:#fff;border:0;padding:14px;border-radius:16px;font-weight:950;font-size:16px;cursor:pointer;transition:.15s}
    .btn-submit:hover{background:#5b21b6}
    .btn-submit:active{transform:scale(.98)}
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
      <a class="active" href="<%=request.getContextPath()%>/patrol/summons/create">
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
          <h1>Create Summons</h1>
          <p>Report a vehicle or student misconduct offense.</p>
        </div>
        <a href="<%=request.getContextPath()%>/patrol/summons/history" class="btn-back">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
            <path d="M15 18l-6-6 6-6" stroke="currentColor" stroke-width="2"/>
          </svg>
          History
        </a>
      </div>

      <!-- Summons Type Toggle -->
      <div class="type-toggle">
        <button type="button" class="type-btn selected" id="btnVehicle" onclick="selectType('VEHICLE')">
          <div class="type-icon icon-vehicle">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
              <path d="M5 17H3v-5l2-5h14l2 5v5h-2" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              <circle cx="7" cy="17" r="2" stroke="currentColor" stroke-width="2"/>
              <circle cx="17" cy="17" r="2" stroke="currentColor" stroke-width="2"/>
            </svg>
          </div>
          <div class="type-label">Vehicle Offense</div>
          <div class="type-desc">Illegal parking, speeding, no helmet</div>
        </button>

        <button type="button" class="type-btn" id="btnMisconduct" onclick="selectType('MISCONDUCT')">
          <div class="type-icon icon-misconduct">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
              <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2" stroke="currentColor" stroke-width="2"/>
              <circle cx="12" cy="7" r="4" stroke="currentColor" stroke-width="2"/>
            </svg>
          </div>
          <div class="type-label">Misconduct</div>
          <div class="type-desc">Smoking, no matric card, improper attire</div>
        </button>
      </div>

      <!-- Form -->
      <form action="<%=request.getContextPath()%>/patrol/summons/create" 
            method="post" enctype="multipart/form-data">
        <input type="hidden" name="summonsType" id="summonsType" value="VEHICLE"/>

        <!-- Identifier Section -->
        <div class="form-card">
          <div class="form-card-title">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
              <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2" stroke="#6f3cff" stroke-width="2"/>
              <circle cx="12" cy="7" r="4" stroke="#6f3cff" stroke-width="2"/>
            </svg>
            Identification
          </div>

          <!-- Vehicle: Plate Number -->
          <div id="fieldPlate" class="form-group">
            <label class="form-label-custom">Plate Number *</label>
            <input type="text" name="plateNumber" id="plateNumber"
                   class="form-input-custom" placeholder="e.g. VHR1461"
                   style="text-transform:uppercase"
                   oninput="lookupPlate(this.value)"
                   autocomplete="off"/>
            <div class="field-note">Enter the vehicle plate number found at the scene</div>

            <!-- Loading Panel -->
            <div id="loadingPanel" style="display:none;margin-top:10px">
              <div style="background:#f9fafb;border:1.5px solid #e5e7eb;
                          border-radius:14px;padding:12px 16px;text-align:center">
                <div style="font-size:13px;font-weight:700;color:#6b7280">
                  🔍 Searching vehicle owner...
                </div>
              </div>
            </div>

            <!-- Student Found Panel -->
            <div id="studentInfoPanel" style="display:none;margin-top:10px">
              <div style="background:#f0fdf4;border:1.5px solid #bbf7d0;
                          border-radius:14px;padding:16px">
                <div style="font-size:11px;font-weight:900;color:#15803d;
                            text-transform:uppercase;letter-spacing:.08em;
                            margin-bottom:12px">
                  ✓ Vehicle Owner Found
                </div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
                  <div>
                    <div style="font-size:11px;color:#6b7280;font-weight:700;
                                margin-bottom:2px">Student Name</div>
                    <div id="infoStudentName" 
                         style="font-weight:950;color:#111827;font-size:14px"></div>
                  </div>
                  <div>
                    <div style="font-size:11px;color:#6b7280;font-weight:700;
                                margin-bottom:2px">Matric No</div>
                    <div id="infoMatricNo" 
                         style="font-weight:950;color:#6f3cff;font-size:14px"></div>
                  </div>
                  <div>
                    <div style="font-size:11px;color:#6b7280;font-weight:700;
                                margin-bottom:2px">Faculty</div>
                    <div id="infoFaculty" 
                         style="font-weight:950;color:#111827;font-size:14px"></div>
                  </div>
                  <div>
                    <div style="font-size:11px;color:#6b7280;font-weight:700;
                                margin-bottom:2px">Vehicle</div>
                    <div id="infoVehicle" 
                         style="font-weight:950;color:#111827;font-size:14px"></div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Not Found Panel -->
            <div id="notFoundPanel" style="display:none;margin-top:10px">
              <div style="background:#fef2f2;border:1.5px solid #fecaca;
                          border-radius:14px;padding:12px 16px">
                <div style="font-size:13px;font-weight:700;color:#dc2626">
                  ✕ Plate number not found or vehicle not yet approved.
                </div>
              </div>
            </div>
          </div>

          <!-- Misconduct: Matric Number -->
          <div id="fieldMatric" class="form-group" style="display:none">
            <label class="form-label-custom">Matric Number *</label>
            <input type="text" name="matricNo" id="matricNo"
                   class="form-input-custom" placeholder="e.g. S70611"
                   style="text-transform:uppercase"/>
            <div class="field-note">Enter the student matric number from their ID card</div>
          </div>
        </div>

        <!-- Offense Details -->
        <div class="form-card">
          <div class="form-card-title">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
              <path d="M12 9v4m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"
                    stroke="#6f3cff" stroke-width="2" stroke-linecap="round"/>
            </svg>
            Offense Details
          </div>

          <!-- Offense Type Dropdown -->
          <div class="form-group">
            <label class="form-label-custom">Offense Type *</label>
            <select name="offenseId" id="offenseSelect" 
                    class="form-input-custom" onchange="updateAmount()" required>
              <option value="">-- Select Offense Type --</option>
              <% if (offenseList != null) {
                   for (OffenseType o : offenseList) { %>
              <option value="<%= o.getOffenseId() %>"
                      data-amount="<%= o.getAmount() %>"
                      data-category="<%= o.getOffenseCategory() %>"
                      <%= o.getOffenseCategory().equals("VEHICLE") ? "" : "class='opt-misconduct'" %>>
                <%= o.getOffenseName() %> 
                (RM <%= String.format("%.2f", o.getAmount()) %>)
              </option>
              <% } } %>
            </select>
          </div>

          <!-- Auto-filled Amount -->
          <div class="form-group">
            <label class="form-label-custom">Fine Amount (RM)</label>
            <div class="amount-display" id="amountDisplay">
              Select an offense type to see the fine amount
            </div>
            <input type="hidden" name="amount" id="amountInput" value="0"/>
          </div>

          <!-- Location -->
          <div class="form-group">
            <label class="form-label-custom">Location *</label>
            <select name="location" class="form-input-custom" required>
              <option value="" disabled selected>-- Select Location --</option>
              <optgroup label="Parking Areas">
                <option>Parking Lot A - Fakulti Sains &amp; Sekitaran Marin (FSSM)</option>
                <option>Parking Lot B - Fakulti Perikanan &amp; Sains Makanan (FPSM)</option>
                <option>Parking Lot C - Fakulti Teknologi Kejuruteraan Kelautan &amp; Informatik (FTKKI)</option>
                <option>Parking Lot D - Fakulti Perniagaan, Ekonomi &amp; Pembangunan Sosial (FPEPS)</option>
                <option>Parking Lot E - Pusat Asasi STEM (PASTEM)</option>
                <option>Parking Lot F - Kolej Kediaman</option>
                <option>Parking Lot G - Fakulti Pengajian Maritim (FPM)</option>
                <option>Parking Lot H - Kompleks Sukan</option>
                <option>Parking Lot I - Medan Syarahan</option>
                <option>Parking Lot J - UMTCC</option>
                <option>Parking Lot K - Pusat Islam Sultan Mahmud (PISM)</option>
                <option>Parking Lot L - Kompleks Kuliah</option>
              </optgroup>
              <optgroup label="Academic Zone">
                <option>Laluan Pejalan Kaki - Zon Akademik</option>
                <option>Perpustakaan Sultanah Nur Zahirah (PSNZ)</option>
                <option>Bangunan Canselori UMT</option>
                <option>Pusat Kesihatan UMT</option>
              </optgroup>
              <optgroup label="Facilities">
                <option>Pusat Kesihatan Universiti (PKU)</option>
                <option>Kompleks Siswa</option>
                <option>Komplkes Sukan</option>
              </optgroup>
              <optgroup label="Residential">
                <option>Kolej Kediaman Tun Hussien Onn (KTHO)</option>
              </optgroup>
              <optgroup label="Entrance">
                <option>Pintu Masuk Utama (Guard House)</option>
              </optgroup>
            </select>
          </div>

          <!-- Additional Description -->
          <div class="form-group">
            <label class="form-label-custom">Additional Notes (Optional)</label>
            <textarea name="description" class="form-input-custom" rows="3"
                      placeholder="Any additional details about the offense..."></textarea>
          </div>
        </div>

        <!-- Evidence Upload -->
        <div class="form-card">
          <div class="form-card-title">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
              <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4" stroke="#6f3cff" stroke-width="2"/>
              <polyline points="17 8 12 3 7 8" stroke="#6f3cff" stroke-width="2"/>
              <line x1="12" y1="3" x2="12" y2="15" stroke="#6f3cff" stroke-width="2"/>
            </svg>
            Evidence Photo (Optional)
          </div>

          <div class="upload-area" id="uploadArea" onclick="document.getElementById('evidenceInput').click()">
            <div class="upload-icon">
              <svg width="36" height="36" viewBox="0 0 24 24" fill="none">
                <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4" stroke="currentColor" stroke-width="2"/>
                <polyline points="17 8 12 3 7 8" stroke="currentColor" stroke-width="2"/>
                <line x1="12" y1="3" x2="12" y2="15" stroke="currentColor" stroke-width="2"/>
              </svg>
            </div>
            <div class="upload-text">Click to upload evidence photo</div>
            <div class="upload-sub">PNG, JPG or JPEG (max 5MB)</div>
            <img id="previewImg" class="preview-img" src="" alt="Preview"/>
          </div>
          <input type="file" name="evidenceImage" id="evidenceInput"
                 accept="image/*" style="display:none" onchange="previewImage(this)"/>
        </div>

        <!-- Submit -->
        <button type="submit" class="btn-submit">
          Submit Summons Report
        </button>

      </form>
    </div><!-- end content -->
  </main>
</div>

<script>
  // ── Plate Number AJAX Lookup ──
  let lookupTimer = null;

  function lookupPlate(value) {
    // Reset all panels
    document.getElementById("studentInfoPanel").style.display = "none";
    document.getElementById("notFoundPanel").style.display    = "none";
    document.getElementById("loadingPanel").style.display     = "none";

    const plate = value.trim().toUpperCase();

    // Only search if plate is at least 4 characters
    if (plate.length < 4) return;

    // Debounce — wait 600ms after user stops typing
    clearTimeout(lookupTimer);
    lookupTimer = setTimeout(function() {

      document.getElementById("loadingPanel").style.display = "";

      fetch("<%=request.getContextPath()%>/patrol/lookup/plate?plate=" +
            encodeURIComponent(plate))
        .then(function(res) { return res.json(); })
        .then(function(data) {

          document.getElementById("loadingPanel").style.display = "none";

          if (data.found === "true") {
            // Populate student info
            document.getElementById("infoStudentName").textContent = data.studentName;
            document.getElementById("infoMatricNo").textContent    = data.matricNo;
            document.getElementById("infoFaculty").textContent     = data.faculty;
            document.getElementById("infoVehicle").textContent     =
              data.brand + " • " + data.vehicleType + " • " + data.color;

            // Show found panel
            document.getElementById("studentInfoPanel").style.display = "";

          } else {
            // Show not found panel
            document.getElementById("notFoundPanel").style.display = "";
          }
        })
        .catch(function(err) {
          document.getElementById("loadingPanel").style.display    = "none";
          document.getElementById("notFoundPanel").style.display   = "";
          console.error("Lookup error:", err);
        });

    }, 600); // 600ms debounce delay
  }

  // ── Offense type data from server ──
  const offenseData = {};
  <% if (offenseList != null) {
       for (OffenseType o : offenseList) { %>
  offenseData["<%= o.getOffenseId() %>"] = {
    amount  : <%= o.getAmount() %>,
    category: "<%= o.getOffenseCategory() %>"
  };
  <% } } %>

  // ── Select summons type (VEHICLE or MISCONDUCT) ──
  function selectType(type) {
    document.getElementById("summonsType").value = type;

    // Toggle buttons
    document.getElementById("btnVehicle").classList.toggle("selected", type === "VEHICLE");
    document.getElementById("btnMisconduct").classList.toggle("selected", type === "MISCONDUCT");

    // Toggle identifier fields
    document.getElementById("fieldPlate").style.display  = type === "VEHICLE"     ? "" : "none";
    document.getElementById("fieldMatric").style.display = type === "MISCONDUCT"  ? "" : "none";

    // Toggle required
    document.getElementById("plateNumber").required = type === "VEHICLE";
    document.getElementById("matricNo").required    = type === "MISCONDUCT";

    // Filter offense dropdown
    filterOffenseDropdown(type);

    // Reset amount
    document.getElementById("amountDisplay").textContent = "Select an offense type to see the fine amount";
    document.getElementById("amountInput").value = "0";
    document.getElementById("offenseSelect").value = "";
  }

  // ── Filter offense dropdown by category ──
  function filterOffenseDropdown(type) {
    const select  = document.getElementById("offenseSelect");
    const options = select.querySelectorAll("option");

    options.forEach(opt => {
      if (!opt.value) return; // keep placeholder
      const cat = opt.getAttribute("data-category");
      opt.style.display = cat === type ? "" : "none";
    });

    select.value = "";
  }

  // ── Auto-fill amount when offense selected ──
  function updateAmount() {
    const select   = document.getElementById("offenseSelect");
    const offenseId = select.value;

    if (!offenseId || !offenseData[offenseId]) {
      document.getElementById("amountDisplay").textContent = "Select an offense type to see the fine amount";
      document.getElementById("amountInput").value = "0";
      return;
    }

    const data   = offenseData[offenseId];
    const amount = data.amount.toFixed(2);

    document.getElementById("amountDisplay").textContent = "RM " + amount;
    document.getElementById("amountInput").value = amount;
  }

  // ── Preview evidence image ──
  function previewImage(input) {
    const preview   = document.getElementById("previewImg");
    const uploadArea = document.getElementById("uploadArea");

    if (input.files && input.files[0]) {
      const reader = new FileReader();
      reader.onload = function(e) {
        preview.src = e.target.result;
        preview.style.display = "block";
        uploadArea.classList.add("has-file");
      };
      reader.readAsDataURL(input.files[0]);
    }
  }

  // ── Sidebar ──
  function openSidebar(){
    document.getElementById("sidebar").classList.add("show");
    document.getElementById("overlay").classList.add("show");
  }
  function closeSidebar(){
    document.getElementById("sidebar").classList.remove("show");
    document.getElementById("overlay").classList.remove("show");
  }

  // ── Init: filter dropdown for default VEHICLE type ──
  window.onload = function() {
    filterOffenseDropdown("VEHICLE");
  };
</script>

</body>
</html>
