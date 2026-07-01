<%-- 
    Document   : appeal_submit.jsp (Student)
    Author     : SHAHRUL
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Student"%>
<%@page import="model.Summons"%>
<%
    Student s = (Student) session.getAttribute("student");
    if (s == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

    Summons summons = (Summons) request.getAttribute("summons");
    if (summons == null) { response.sendRedirect(request.getContextPath() + "/student/summons"); return; }

    String errorMsg   = (String) session.getAttribute("errorMsg");
    session.removeAttribute("errorMsg");

    int unpaidSummons = 0;
    try {
        dao.SummonsDAO sd = new dao.SummonsDAO();
        unpaidSummons = sd.countByStatusForStudent(s.getMatricNo(), s.getStudentId(), "UNPAID");
    } catch (Exception e) {}
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Submit Appeal | Smart Campus</title>
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

    /* ── Content constraint ── */
    .content{padding:24px 20px;max-width:680px}

    /* ── Summons Card ── */
    .summons-card{background:linear-gradient(135deg,#6f3cff,#4338ca);border-radius:22px;padding:22px 24px;color:#fff;margin-bottom:24px}
    .summons-card h3{margin:0 0 4px;font-weight:950;font-size:18px}
    .summons-card p{margin:0;color:#e9d5ff;font-weight:600;font-size:13px}
    .summons-amount{font-size:36px;font-weight:950;margin-top:12px}
    .summons-meta{display:flex;gap:12px;margin-top:12px;flex-wrap:wrap}
    .meta-item{background:rgba(255,255,255,.15);border-radius:10px;padding:7px 12px}
    .meta-label{font-size:10px;color:#e9d5ff;font-weight:700;text-transform:uppercase}
    .meta-value{font-size:13px;font-weight:950;margin-top:2px}

    /* ── Form Card ── */
    .form-card{background:#fff;border:1px solid #e5e7eb;border-radius:22px;padding:24px;box-shadow:0 4px 12px rgba(17,24,39,.04);margin-bottom:20px}
    .form-card-title{font-size:16px;font-weight:950;color:#111827;margin-bottom:18px;display:flex;align-items:center;gap:8px}
    .form-label-custom{font-size:12px;font-weight:900;color:#374151;text-transform:uppercase;letter-spacing:.08em;margin-bottom:6px;display:block}
    .form-input-custom{width:100%;border:1.5px solid #e5e7eb;border-radius:12px;padding:11px 14px;font-weight:600;color:#111827;background:#f9fafb;font-size:14px;outline:none;box-sizing:border-box;transition:.15s;resize:vertical}
    .form-input-custom:focus{border-color:#6f3cff;background:#fff;box-shadow:0 0 0 3px rgba(111,60,255,.08)}
    .char-count{font-size:11px;color:#9ca3af;font-weight:600;margin-top:4px;text-align:right}
    .char-count.good{color:#16a34a}

    /* ── Guidelines ── */
    .guidelines{background:#f0fdf4;border:1.5px solid #bbf7d0;border-radius:14px;padding:16px 20px;margin-bottom:20px}
    .guidelines h4{font-weight:950;color:#15803d;margin:0 0 10px;font-size:14px}
    .guidelines ul{margin:0;padding-left:18px}
    .guidelines li{font-size:13px;color:#15803d;font-weight:600;margin-bottom:4px}

    /* ── Warning Box ── */
    .warning-box{background:#fff7ed;border:1.5px solid #ffedd5;border-radius:14px;padding:14px 18px;margin-bottom:20px}
    .warning-box p{font-size:13px;color:#ea580c;font-weight:700;margin:0}

    /* ── Submit Button ── */
    .btn-submit{width:100%;background:#6f3cff;color:#fff;border:0;padding:14px;border-radius:14px;font-weight:950;font-size:15px;cursor:pointer;transition:.15s}
    .btn-submit:hover{background:#5b21b6}
    .btn-submit:disabled{background:#9ca3af;cursor:not-allowed}
  </style>
</head>
<body>
<div id="overlay" class="overlay" onclick="closeSidebar()"></div>
<div class="app">

  <!-- SIDEBAR -->
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
      <a href="<%=request.getContextPath()%>/student/summons">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z" stroke="currentColor" stroke-width="2"/><path d="M14 2v6h6" stroke="currentColor" stroke-width="2"/></svg>
        My Summons
        <% if (unpaidSummons > 0) { %><span class="notif-badge"><%= unpaidSummons %></span><% } %>
      </a>
      <a class="active" href="<%=request.getContextPath()%>/student/appeal/list">
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

  <!-- MAIN -->
  <main class="main">
    <header class="header">
      <button class="hamburger d-lg-none" onclick="openSidebar()">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none"><path d="M4 6h16M4 12h16M4 18h16" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
      </button>
      <div class="portal-title">STUDENT Portal</div>
      <div class="userbox">
        <div class="usertext">
          <div style="font-weight:900;color:#111827;font-size:14px"><%= s.getStudentName() %></div>
          <div style="font-size:11px;color:#6b7280;font-weight:900;letter-spacing:.10em;text-transform:uppercase"><%= s.getMatricNo() %></div>
        </div>
        <div class="avatar"><%= s.getStudentName().substring(0,1).toUpperCase() %></div>
      </div>
    </header>

    <div class="content">

      <% if (errorMsg != null) { %><div class="alert-error">✕ <%= errorMsg %></div><% } %>

      <a href="<%=request.getContextPath()%>/student/summons" class="btn-back">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M15 18l-6-6 6-6" stroke="currentColor" stroke-width="2"/></svg>
        Back to Summons
      </a>

      <!-- Summons Info -->
      <div class="summons-card">
        <h3><%= summons.getSummonsId() %></h3>
        <p><%= summons.getOffenseName() != null ? summons.getOffenseName() : summons.getSummonsType() %></p>
        <div class="summons-amount">RM <%= String.format("%.2f", summons.getAmount()) %></div>
        <div class="summons-meta">
          <div class="meta-item">
            <div class="meta-label">Date</div>
            <div class="meta-value"><%= summons.getSummonsDate() %></div>
          </div>
          <div class="meta-item">
            <div class="meta-label">Type</div>
            <div class="meta-value"><%= summons.getSummonsType() %></div>
          </div>
          <div class="meta-item">
            <div class="meta-label">Location</div>
            <div class="meta-value"><%= summons.getLocation() %></div>
          </div>
        </div>
      </div>

      <!-- Guidelines -->
      <div class="guidelines">
        <h4>📋 Appeal Guidelines</h4>
        <ul>
          <li>Be truthful and provide accurate information</li>
          <li>Include supporting evidence or context if available</li>
          <li>Appeals are reviewed within 3–5 working days</li>
          <li>Frivolous appeals may result in additional penalties</li>
          <li>You can only submit one appeal per summons</li>
        </ul>
      </div>

      <!-- Warning -->
      <div class="warning-box">
        <p>⚠️ Once submitted, your appeal cannot be edited or withdrawn. The summons status will change to <b>APPEALED</b> while under review.</p>
      </div>

      <!-- Appeal Form -->
      <div class="form-card">
        <div class="form-card-title">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z" stroke="#6f3cff" stroke-width="2" stroke-linejoin="round"/></svg>
          Your Appeal Statement
        </div>

        <form action="<%=request.getContextPath()%>/student/appeal/submit" method="post">
          <input type="hidden" name="summonsId" value="<%= summons.getSummonsId() %>"/>

          <div style="margin-bottom:16px">
            <label class="form-label-custom">Reason for Appeal *</label>
            <textarea name="appealReason" id="appealReason" class="form-input-custom"
                      rows="6" minlength="20" maxlength="500" required
                      oninput="countChars(this)"
                      placeholder="Explain clearly why you believe this summons should be reconsidered. Include any relevant circumstances, evidence, or context..."></textarea>
            <div class="char-count" id="charCount">0 / 500 characters (minimum 20)</div>
          </div>

          <button type="submit" class="btn-submit" id="submitBtn" disabled>
            Submit Appeal
          </button>
        </form>
      </div>

    </div>
  </main>
</div>

<script>
  function countChars(textarea) {
    const len = textarea.value.trim().length;
    const counter = document.getElementById("charCount");
    const btn     = document.getElementById("submitBtn");

    counter.textContent = len + " / 500 characters (minimum 20)";

    if (len >= 20) {
      counter.classList.add("good");
      btn.disabled = false;
    } else {
      counter.classList.remove("good");
      btn.disabled = true;
    }
  }

  function openSidebar(){document.getElementById("sidebar").classList.add("show");document.getElementById("overlay").classList.add("show");}
  function closeSidebar(){document.getElementById("sidebar").classList.remove("show");document.getElementById("overlay").classList.remove("show");}
</script>
</body>
</html>