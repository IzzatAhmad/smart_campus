<%-- report.jsp — Clerical Staff: Analytics & Reports --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.ClericalStaff"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%
    ClericalStaff c = (ClericalStaff) session.getAttribute("clerical");
    if (c == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

    int selectedYear  = (int) request.getAttribute("selectedYear");
    int selectedMonth = (int) request.getAttribute("selectedMonth");

    Map<String, String>       summary        = (Map<String, String>)       request.getAttribute("summary");
    List<Map<String, String>> monthlySummons = (List<Map<String, String>>) request.getAttribute("monthlySummons");
    List<Map<String, String>> monthlyPayments= (List<Map<String, String>>) request.getAttribute("monthlyPayments");
    List<Map<String, String>> offenseTypes   = (List<Map<String, String>>) request.getAttribute("offenseTypes");
    List<Map<String, String>> hotspots       = (List<Map<String, String>>) request.getAttribute("hotspots");
    List<Map<String, String>> monthlyDetail  = (List<Map<String, String>>) request.getAttribute("monthlyDetail");
    List<Integer>             availableYears = (List<Integer>)             request.getAttribute("availableYears");

    String currentPage = request.getRequestURI();

    // Build JSON arrays for Chart.js
    String[] monthLabels = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};

    // Monthly summons arrays
    int[] summonsArr  = new int[12];
    int[] vehicleArr  = new int[12];
    int[] miscondArr  = new int[12];
    for (Map<String, String> row : monthlySummons) {
        int m = Integer.parseInt(row.get("month")) - 1;
        summonsArr[m] = Integer.parseInt(row.get("total"));
        vehicleArr[m] = Integer.parseInt(row.get("vehicle"));
        miscondArr[m] = Integer.parseInt(row.get("misconduct"));
    }

    // Monthly payment arrays
    double[] collectedArr = new double[12];
    for (Map<String, String> row : monthlyPayments) {
        int m = Integer.parseInt(row.get("month")) - 1;
        collectedArr[m] = Double.parseDouble(row.get("totalCollected"));
    }

    // Offense pie data
    StringBuilder pieLabels = new StringBuilder();
    StringBuilder pieData   = new StringBuilder();
    for (int i = 0; i < offenseTypes.size(); i++) {
        if (i > 0) { pieLabels.append(","); pieData.append(","); }
        pieLabels.append("\"").append(offenseTypes.get(i).get("offenseName")).append("\"");
        pieData.append(offenseTypes.get(i).get("count"));
    }

    // Max hotspot count for bar width
    int maxHotspot = hotspots.isEmpty() ? 1 : Integer.parseInt(hotspots.get(0).get("count"));

    int pendingAppeals = 0; int pendingPayments = 0; int pendingVehicles = 0;
    try {
        pendingAppeals  = new dao.AppealDAO().countPendingAppeals();
        try (java.sql.Connection _con = util.DBConnection.getConnection();
             java.sql.PreparedStatement _ps1 = _con.prepareStatement("SELECT COUNT(*) FROM payment WHERE status='PENDING_OFFICE'");
             java.sql.PreparedStatement _ps2 = _con.prepareStatement("SELECT COUNT(*) FROM vehicle WHERE status='PENDING'")) {
            try (java.sql.ResultSet _rs = _ps1.executeQuery()) { if (_rs.next()) pendingPayments = _rs.getInt(1); }
            try (java.sql.ResultSet _rs = _ps2.executeQuery()) { if (_rs.next()) pendingVehicles = _rs.getInt(1); }
        }
    } catch (Exception _ex) {}
    // ── WEKA Prediction attributes (set by ReportServlet) ──
    double predictedNextMonth = request.getAttribute("predictedNextMonth") != null
        ? (double) request.getAttribute("predictedNextMonth") : -1.0;
    int riskHigh   = request.getAttribute("riskHigh")   != null ? (int) request.getAttribute("riskHigh")   : 0;
    int riskMedium = request.getAttribute("riskMedium") != null ? (int) request.getAttribute("riskMedium") : 0;
    int riskLow    = request.getAttribute("riskLow")    != null ? (int) request.getAttribute("riskLow")    : 0;
    java.util.List<java.util.Map<String, String>> hotspotClusters = new java.util.ArrayList<java.util.Map<String, String>>();
    if (request.getAttribute("hotspotClusters") != null) {
        hotspotClusters = (java.util.List<java.util.Map<String, String>>) request.getAttribute("hotspotClusters");
    }

%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Analytics & Reports | Smart Campus</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
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
    .main{flex:1;min-width:0;margin-left:260px;display:flex;flex-direction:column}
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

    /* ── Shared Alerts ── */
    .alert-success{background:#f0fdf4;border:1px solid #bbf7d0;color:#15803d;border-radius:14px;padding:12px 16px;font-weight:700;margin-bottom:16px}
    .alert-error{background:#fef2f2;border:1px solid #fecaca;color:#dc2626;border-radius:14px;padding:12px 16px;font-weight:700;margin-bottom:16px}

    /* ── Shared Pills ── */
    .status-pill{font-size:10px;font-weight:950;text-transform:uppercase;letter-spacing:.08em;padding:5px 10px;border-radius:999px;display:inline-block}
    .pill-unpaid{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}
    .pill-paid{background:#f0fdf4;color:#16a34a;border:1px solid #dcfce7}
    .pill-appealed{background:#eff6ff;color:#2563eb;border:1px solid #dbeafe}
    .pill-overdue{background:#fef2f2;color:#dc2626;border:1px solid #fee2e2}
    .pill-pending{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}
    .type-pill{font-size:10px;font-weight:950;text-transform:uppercase;padding:5px 10px;border-radius:999px;display:inline-block}
    .type-vehicle{background:#eff6ff;color:#2563eb;border:1px solid #dbeafe}
    .type-misconduct{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}

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
    .btn-purple{background:#6f3cff;border:0;color:#fff;font-weight:900;border-radius:14px;padding:10px 16px;box-shadow:0 12px 26px rgba(111,60,255,.18);display:inline-flex;align-items:center;gap:8px;cursor:pointer}
    .btn-purple:hover{background:#5b21b6;color:#fff}

    /* ── Shared Table Card ── */
    .table-card{background:#fff;border:1px solid #e5e7eb;border-radius:20px;box-shadow:0 4px 12px rgba(17,24,39,.04);overflow:hidden}
    .table-card table{width:100%;border-collapse:collapse;min-width:600px}
    .table-card thead{background:#f9fafb}
    .table-card th{font-size:11px;text-transform:uppercase;letter-spacing:.12em;color:#6b7280;font-weight:950;padding:14px 16px;border-bottom:1px solid #f1f5f9}
    .table-card td{padding:14px 16px;border-bottom:1px solid #f1f5f9;vertical-align:middle}
    .table-card tr:last-child td{border-bottom:0}
    .table-card tr:hover td{background:#fafafa}

    /* ── Shared Filter Bar ── */
    .filter-bar{background:#fff;border:1px solid #e5e7eb;border-radius:18px;padding:14px 18px;margin-bottom:18px;display:flex;align-items:center;gap:12px;flex-wrap:wrap}
    .filter-bar input,.filter-bar select{border:1px solid #e5e7eb;border-radius:10px;padding:8px 12px;font-weight:700;color:#374151;background:#f9fafb;font-size:13px;outline:none}
    .filter-bar input:focus,.filter-bar select:focus{border-color:#6f3cff;background:#fff}

    /* ── Shared Card ── */
    .cardx{background:#fff;border:1px solid #e5e7eb;border-radius:22px;padding:22px;box-shadow:0 4px 12px rgba(17,24,39,.04)}

    /* ── Responsive ── */
    @media(max-width:992px){
      .main{margin-left:0}
      .sidebar{transform:translateX(-100%)}
      .sidebar.show{transform:translateX(0)}
      .chart-grid{grid-template-columns:1fr}
      .stat-row{grid-template-columns:repeat(2,1fr)}
      .usertext{display:block}
    }

    /* ── Content ── */
    .content{padding:24px 28px}

    /* ── Filter bar (form-based) ── */
    .report-filter{display:flex;gap:12px;align-items:center;flex-wrap:wrap;margin-bottom:24px;background:#fff;border:1px solid #e5e7eb;border-radius:16px;padding:16px 20px}
    .report-filter label{font-size:12px;font-weight:900;color:#374151;text-transform:uppercase;letter-spacing:.08em}
    .filter-select{border:1.5px solid #e5e7eb;border-radius:10px;padding:8px 12px;font-weight:700;font-size:13px;color:#111827;background:#f9fafb;cursor:pointer}
    .filter-select:focus{outline:none;border-color:#6f3cff}
    .btn-filter{background:#6f3cff;color:#fff;border:0;border-radius:10px;padding:9px 20px;font-weight:900;font-size:13px;cursor:pointer}
    .btn-filter:hover{background:#5b21b6}

    /* ── Export buttons ── */
    .export-bar{display:flex;gap:10px;margin-bottom:24px;flex-wrap:wrap;align-items:center}
    .btn-excel{background:#16a34a;color:#fff;border:0;border-radius:10px;padding:9px 18px;font-weight:900;font-size:13px;cursor:pointer;text-decoration:none;display:inline-flex;align-items:center;gap:8px}
    .btn-excel:hover{background:#15803d;color:#fff}
    .btn-pdf{background:#dc2626;color:#fff;border:0;border-radius:10px;padding:9px 18px;font-weight:900;font-size:13px;cursor:pointer;text-decoration:none;display:inline-flex;align-items:center;gap:8px}
    .btn-pdf:hover{background:#b91c1c;color:#fff}

    /* ── Stat Cards ── */
    .stat-row{display:grid;grid-template-columns:repeat(5,1fr);gap:14px;margin-bottom:24px}
    .stat-card{background:#fff;border:1px solid #e5e7eb;border-radius:16px;padding:18px 20px;box-shadow:0 2px 8px rgba(17,24,39,.04)}
    .stat-label{font-size:11px;font-weight:900;text-transform:uppercase;letter-spacing:.1em;color:#9ca3af;margin-bottom:6px}
    .stat-value{font-size:26px;font-weight:950;color:#111827}
    .stat-sub{font-size:11px;color:#9ca3af;font-weight:700;margin-top:2px}
    .c-total .stat-value{color:#6f3cff}
    .c-paid .stat-value{color:#16a34a}
    .c-unpaid .stat-value{color:#ea580c}
    .c-collect .stat-value{color:#0891b2}
    .c-student .stat-value{color:#7c3aed}

    /* ── Chart Grid ── */
    .chart-grid{display:grid;grid-template-columns:2fr 1fr;gap:16px;margin-bottom:24px}
    .chart-card{background:#fff;border:1px solid #e5e7eb;border-radius:18px;padding:20px;box-shadow:0 2px 8px rgba(17,24,39,.04)}
    .chart-title{font-size:14px;font-weight:950;color:#111827;margin-bottom:16px}
    .chart-wrap{position:relative;height:260px}
    .full-chart-card{background:#fff;border:1px solid #e5e7eb;border-radius:18px;padding:20px;box-shadow:0 2px 8px rgba(17,24,39,.04);margin-bottom:24px}

    /* ── Hotspot ── */
    .hotspot-list{display:flex;flex-direction:column;gap:10px}
    .hotspot-item{display:flex;align-items:center;gap:12px}
    .hotspot-rank{width:26px;height:26px;border-radius:8px;background:#6f3cff;color:#fff;font-size:11px;font-weight:900;display:flex;align-items:center;justify-content:center;flex-shrink:0}
    .hotspot-rank.top1{background:#f59e0b}.hotspot-rank.top2{background:#94a3b8}.hotspot-rank.top3{background:#b45309}
    .hotspot-name{font-size:13px;font-weight:700;color:#111827;flex:1;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .hotspot-bar-wrap{width:80px;background:#f1f5f9;border-radius:999px;height:8px;flex-shrink:0}
    .hotspot-bar{background:#6f3cff;height:8px;border-radius:999px}
    .hotspot-count{font-size:12px;font-weight:900;color:#6b7280;flex-shrink:0;width:20px;text-align:right}

    /* ── Detail Table ── */
    .table-card-header{padding:16px 20px;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;justify-content:space-between}
    .table-card-title{font-size:14px;font-weight:950;color:#111827}
    .badge-paid{background:#f0fdf4;color:#16a34a;font-size:10px;font-weight:900;padding:3px 8px;border-radius:6px}
    .badge-unpaid{background:#fff7ed;color:#ea580c;font-size:10px;font-weight:900;padding:3px 8px;border-radius:6px}
    .badge-vehicle{background:#eff6ff;color:#2563eb;font-size:10px;font-weight:900;padding:3px 8px;border-radius:6px}
    .badge-misconduct{background:#fdf4ff;color:#9333ea;font-size:10px;font-weight:900;padding:3px 8px;border-radius:6px}
    @media(max-width:1200px){.stat-row{grid-template-columns:repeat(3,1fr)}}

    /* ══ WEKA Predictive Analytics ══ */
    .weka-section{margin-bottom:24px}
    .weka-section-title{
      font-size:16px;font-weight:950;color:#111827;
      margin-bottom:16px;padding-bottom:10px;
      border-bottom:2px solid #e4d9f7;
      display:flex;align-items:center;gap:8px;
    }
    .weka-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:16px}
    .forecast-card{
      background:linear-gradient(135deg,#6f3cff,#4338ca);
      border-radius:20px;padding:22px;color:#fff;
      box-shadow:0 8px 24px rgba(111,60,255,.20);
    }
    .weka-model-label{font-size:10px;font-weight:900;text-transform:uppercase;
      letter-spacing:.12em;color:rgba(255,255,255,.65);margin-bottom:6px}
    .weka-card-title{font-size:13px;font-weight:700;color:#e9d5ff;margin-bottom:14px}
    .forecast-value{font-size:44px;font-weight:950;color:#fff;line-height:1}
    .forecast-sub{font-size:12px;color:rgba(255,255,255,.65);font-weight:600;margin-top:6px}
    .weka-note{font-size:11px;font-weight:600;padding:8px 12px;border-radius:10px;margin-top:12px}
    .weka-note-light{background:rgba(255,255,255,.15);color:rgba(255,255,255,.85);border:1px solid rgba(255,255,255,.2)}
    .weka-note-purple{background:#f5f0ff;border:1px solid #e4d9f7;color:#7c3aed}
    .risk-card{background:#fff;border:1px solid #e5e7eb;border-radius:20px;
      padding:22px;box-shadow:0 4px 12px rgba(17,24,39,.04)}
    .weka-model-label-purple{font-size:10px;font-weight:900;text-transform:uppercase;
      letter-spacing:.12em;color:#a78bfa;margin-bottom:6px}
    .risk-bars{display:flex;flex-direction:column;gap:10px}
    .risk-row{display:flex;align-items:center;gap:10px}
    .risk-pill{font-size:10px;font-weight:950;padding:3px 9px;border-radius:6px;width:44px;text-align:center;flex-shrink:0}
    .risk-pill-high{background:#fef2f2;color:#dc2626;border:1px solid #fecaca}
    .risk-pill-med{background:#fff7ed;color:#ea580c;border:1px solid #ffedd5}
    .risk-pill-low{background:#f0fdf4;color:#16a34a;border:1px solid #dcfce7}
    .risk-bar-wrap{flex:1;background:#f1f5f9;border-radius:999px;height:10px}
    .risk-bar{height:10px;border-radius:999px}
    .risk-bar-high{background:#dc2626}
    .risk-bar-med{background:#ea580c}
    .risk-bar-low{background:#16a34a}
    .risk-count{font-size:12px;font-weight:950;color:#374151;width:20px;text-align:right;flex-shrink:0}
    .cluster-card{background:#fff;border:1px solid #e5e7eb;border-radius:20px;
      padding:22px;box-shadow:0 4px 12px rgba(17,24,39,.04)}
    .cluster-list{display:flex;flex-direction:column;gap:8px}
    .cluster-item{display:flex;align-items:center;gap:10px;padding:9px 12px;border-radius:12px}
    .ci-hot{background:#fef2f2;border:1px solid #fecaca}
    .ci-mod{background:#fff7ed;border:1px solid #ffedd5}
    .ci-low{background:#f0fdf4;border:1px solid #dcfce7}
    .cluster-dot{width:9px;height:9px;border-radius:999px;flex-shrink:0}
    .cd-hot{background:#dc2626} .cd-mod{background:#ea580c} .cd-low{background:#16a34a}
    .cluster-loc{flex:1;font-size:12px;font-weight:700;color:#374151;
      overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
    .cluster-zone{font-size:10px;font-weight:900;flex-shrink:0}
    .cz-hot{color:#dc2626} .cz-mod{color:#ea580c} .cz-low{color:#16a34a}
    .cluster-cnt{font-size:11px;font-weight:950;color:#9ca3af;flex-shrink:0;min-width:20px;text-align:right}
    @media(max-width:992px){.weka-grid{grid-template-columns:1fr}}
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
      <a href="<%=request.getContextPath()%>/clerical/dashboard">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M3 13h8V3H3v10zM13 21h8V11h-8v10zM13 3h8v6h-8V3zM3 21h8v-6H3v6z" stroke="currentColor" stroke-width="2"/></svg>
        Overview
      </a>
      <div class="menu-label">Management</div>
      <a href="<%=request.getContextPath()%>/clerical/vehicle/requests">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z" stroke="currentColor" stroke-width="2"/><path d="M14 2v6h6" stroke="currentColor" stroke-width="2"/></svg>
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
      <a class="active" href="<%=request.getContextPath()%>/clerical/report/view">
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

  <!-- MAIN -->
  <main class="main">
    <header class="header">
      <button class="hamburger d-lg-none" onclick="openSidebar()">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none"><path d="M4 6h16M4 12h16M4 18h16" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
      </button>
      <div class="portal-title">CLERICAL Portal</div>
      <div class="header-right">
        <div class="userbox"><div class="avatar"><%= c.getClericalName().substring(0,1).toUpperCase() %></div></div>
      </div>
    </header>

    <div class="content">

      <!-- Page Header -->
      <div class="page-header">
        <h1>Analytics & Reports</h1>
        <p>Summons, payments and collection overview by month and year.</p>
      </div>

      <!-- Filter Bar -->
      <form method="get" action="<%=request.getContextPath()%>/clerical/report/view" class="filter-bar">
        <div>
          <label>Year</label><br>
          <select name="year" class="filter-select">
            <% for (Integer yr : availableYears) { %>
            <option value="<%= yr %>" <%= yr == selectedYear ? "selected" : "" %>><%= yr %></option>
            <% } %>
          </select>
        </div>
        <div>
          <label>Month (for detail table)</label><br>
          <select name="month" class="filter-select">
            <option value="0" <%= selectedMonth == 0 ? "selected" : "" %>>All Months</option>
            <% String[] mNames = {"January","February","March","April","May","June","July","August","September","October","November","December"};
               for (int i = 1; i <= 12; i++) { %>
            <option value="<%= i %>" <%= i == selectedMonth ? "selected" : "" %>><%= mNames[i-1] %></option>
            <% } %>
          </select>
        </div>
        <div style="align-self:flex-end">
          <button type="submit" class="btn-filter">Apply Filter</button>
        </div>
      </form>

      <!-- Export Buttons -->
      <div class="export-bar">
        <a href="<%=request.getContextPath()%>/clerical/report/export/excel?year=<%= selectedYear %>&month=<%= selectedMonth %>"
           class="btn-excel">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z" stroke="currentColor" stroke-width="2"/><path d="M14 2v6h6" stroke="currentColor" stroke-width="2"/></svg>
          Export Excel
        </a>
        <a href="<%=request.getContextPath()%>/clerical/report/export/pdf?year=<%= selectedYear %>&month=<%= selectedMonth %>"
           class="btn-pdf">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z" stroke="currentColor" stroke-width="2"/><path d="M14 2v6h6" stroke="currentColor" stroke-width="2"/></svg>
          Export PDF
        </a>
        <span style="font-size:12px;color:#9ca3af;font-weight:700;align-self:center">
          <%= selectedMonth > 0 ? mNames[selectedMonth-1] + " " + selectedYear : "Full Year " + selectedYear %>
        </span>
      </div>

      <!-- Summary Stats -->
      <div class="stat-row">
        <div class="stat-card c-total">
          <div class="stat-label">Total Summons</div>
          <div class="stat-value"><%= summary.getOrDefault("totalSummons","0") %></div>
          <div class="stat-sub"><%= selectedYear %></div>
        </div>
        <div class="stat-card c-paid">
          <div class="stat-label">Paid</div>
          <div class="stat-value"><%= summary.getOrDefault("totalPaid","0") %></div>
          <div class="stat-sub">Settled summons</div>
        </div>
        <div class="stat-card c-unpaid">
          <div class="stat-label">Unpaid</div>
          <div class="stat-value"><%= summary.getOrDefault("totalUnpaid","0") %></div>
          <div class="stat-sub">Pending payment</div>
        </div>
        <div class="stat-card c-collect">
          <div class="stat-label">Total Collected</div>
          <div class="stat-value" style="font-size:18px">RM <%= summary.getOrDefault("totalCollected","0.00") %></div>
          <div class="stat-sub">Verified payments</div>
        </div>
        <div class="stat-card c-student">
          <div class="stat-label">Students</div>
          <div class="stat-value"><%= summary.getOrDefault("totalStudents","0") %></div>
          <div class="stat-sub">With offenses</div>
        </div>
      </div>

      <!-- Charts Row: Bar + Pie -->
      <div class="chart-grid">
        <!-- Bar Chart -->
        <div class="chart-card">
          <div class="chart-title">📊 Monthly Summons — <%= selectedYear %></div>
          <div class="chart-wrap">
            <canvas id="barChart"></canvas>
          </div>
        </div>

        <!-- Pie Chart -->
        <div class="chart-card">
          <div class="chart-title">🍩 Offense Type Breakdown</div>
          <div class="chart-wrap">
            <canvas id="pieChart"></canvas>
          </div>
        </div>
      </div>

      <!-- Payment Collection Bar Chart -->
      <div class="full-chart-card">
        <div class="chart-title">💰 Monthly Payment Collection (RM) — <%= selectedYear %></div>
        <div style="position:relative;height:220px">
          <canvas id="paymentChart"></canvas>
        </div>
      </div>

      <!-- Hotspot List -->
      <div class="chart-card" style="margin-bottom:24px">
        <div class="chart-title">📍 Top Offense Hotspot Locations — <%= selectedYear %></div>
        <% if (hotspots.isEmpty()) { %>
          <p style="color:#9ca3af;font-weight:700;font-size:13px;text-align:center;padding:20px">No hotspot data available.</p>
        <% } else { %>
        <div class="hotspot-list">
          <% for (int i = 0; i < hotspots.size(); i++) {
               Map<String, String> hs = hotspots.get(i);
               int cnt = Integer.parseInt(hs.get("count"));
               int pct = maxHotspot > 0 ? (cnt * 100 / maxHotspot) : 0;
               String rankClass = i == 0 ? "top1" : (i == 1 ? "top2" : (i == 2 ? "top3" : ""));
          %>
          <div class="hotspot-item">
            <div class="hotspot-rank <%= rankClass %>"><%= i+1 %></div>
            <div class="hotspot-name"><%= hs.get("location") %></div>
            <div class="hotspot-bar-wrap">
              <div class="hotspot-bar" style="width:<%= pct %>%"></div>
            </div>
            <div class="hotspot-count"><%= cnt %></div>
          </div>
          <% } %>
        </div>
        <% } %>
      </div>

      <!-- Monthly Detail Table -->
      <% if (!monthlyDetail.isEmpty()) { %>
      <div class="table-card">
        <div class="table-card-header">
          <div class="table-card-title">
            📋 Detail: <%= mNames[selectedMonth-1] %> <%= selectedYear %>
            — <%= monthlyDetail.size() %> records
          </div>
        </div>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Summons ID</th><th>Date</th><th>Type</th><th>Offense</th>
                <th>Location</th><th>Amount</th><th>Status</th>
                <th>Student</th><th>Matric</th><th>Pay Method</th><th>Pay Date</th>
              </tr>
            </thead>
            <tbody>
              <% for (Map<String, String> row : monthlyDetail) { %>
              <tr>
                <td style="color:#6f3cff;font-weight:950"><%= row.get("summonsId") %></td>
                <td><%= row.get("summonsDate") %></td>
                <td>
                  <% if ("VEHICLE".equals(row.get("summonsType"))) { %>
                    <span class="badge-vehicle">Vehicle</span>
                  <% } else { %>
                    <span class="badge-misconduct">Misconduct</span>
                  <% } %>
                </td>
                <td><%= row.get("offenseName") %></td>
                <td style="color:#6b7280"><%= row.get("location") %></td>
                <td style="font-weight:950">RM <%= row.get("amount") %></td>
                <td>
                  <% if ("PAID".equals(row.get("status"))) { %>
                    <span class="badge-paid">PAID</span>
                  <% } else { %>
                    <span class="badge-unpaid"><%= row.get("status") %></span>
                  <% } %>
                </td>
                <td><%= row.get("studentName") %></td>
                <td style="color:#6b7280"><%= row.get("matricNo") %></td>
                <td><%= row.get("paymentMethod") %></td>
                <td style="color:#6b7280"><%= row.get("paymentDate") %></td>
              </tr>
              <% } %>
            </tbody>
          </table>
        </div>
      </div>
      <% } else if (selectedMonth > 0) { %>
      <div style="text-align:center;padding:40px;color:#9ca3af;font-weight:700">
        No records found for <%= mNames[selectedMonth-1] %> <%= selectedYear %>.
      </div>
      <% } %>


      <!-- ══════════════════════════════════════════════════════
           WEKA PREDICTIVE ANALYTICS
      ══════════════════════════════════════════════════════ -->
      <div class="weka-section">
        <div class="weka-section-title">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
            <path d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
          Predictive Analytics — WEKA Models
        </div>

        <div class="weka-grid">

          <!-- Model 1: SimpleLinearRegression -->
          <div class="forecast-card">
            <div class="weka-model-label">Model 1 &middot; Simple Linear Regression</div>
            <div class="weka-card-title">Predicted Summons &mdash; Next Month</div>
            <% if (predictedNextMonth >= 0) { %>
              <div class="forecast-value"><%= String.format("%.0f", predictedNextMonth) %></div>
              <div class="forecast-sub">estimated based on historical monthly trend</div>
            <% } else { %>
              <div style="font-size:14px;font-weight:700;color:rgba(255,255,255,.8);margin-top:8px">
                Insufficient data to forecast.<br>
                <span style="font-size:12px;font-weight:600;color:rgba(255,255,255,.6)">
                  Minimum 3 months of records required.
                </span>
              </div>
            <% } %>
            <div class="weka-note weka-note-light">
              Trained on monthly summons totals &middot; Predicts volume for upcoming month
            </div>
          </div>

          <!-- Model 2: J48 Decision Tree -->
          <div class="risk-card">
            <div class="weka-model-label-purple">Model 2 &middot; J48 Decision Tree</div>
            <div style="font-size:13px;font-weight:700;color:#374151;margin-bottom:14px">Student Risk Classification</div>
            <% int totalRisk = riskHigh + riskMedium + riskLow;
               int maxRisk   = Math.max(1, Math.max(riskHigh, Math.max(riskMedium, riskLow)));
               if (totalRisk > 0) { %>
            <div class="risk-bars">
              <div class="risk-row">
                <span class="risk-pill risk-pill-high">HIGH</span>
                <div class="risk-bar-wrap"><div class="risk-bar risk-bar-high" style="width:<%= riskHigh * 100 / maxRisk %>%"></div></div>
                <span class="risk-count"><%= riskHigh %></span>
              </div>
              <div class="risk-row">
                <span class="risk-pill risk-pill-med">MED</span>
                <div class="risk-bar-wrap"><div class="risk-bar risk-bar-med" style="width:<%= riskMedium * 100 / maxRisk %>%"></div></div>
                <span class="risk-count"><%= riskMedium %></span>
              </div>
              <div class="risk-row">
                <span class="risk-pill risk-pill-low">LOW</span>
                <div class="risk-bar-wrap"><div class="risk-bar risk-bar-low" style="width:<%= riskLow * 100 / maxRisk %>%"></div></div>
                <span class="risk-count"><%= riskLow %></span>
              </div>
            </div>
            <div class="weka-note weka-note-purple"><%= totalRisk %> students classified &middot; <b><%= riskHigh %></b> high-risk require attention</div>
            <% } else { %>
            <p style="color:#9ca3af;font-size:13px;font-weight:700;margin-top:12px">No student summons data available.</p>
            <% } %>
          </div>

          <!-- Model 3: SimpleKMeans -->
          <div class="cluster-card">
            <div class="weka-model-label-purple">Model 3 &middot; SimpleKMeans Clustering</div>
            <div style="font-size:13px;font-weight:700;color:#374151;margin-bottom:14px">Offense Hotspot Zone Detection</div>
            <% if (hotspotClusters != null && !hotspotClusters.isEmpty()) { %>
            <div class="cluster-list">
            <% int climit = 0;
               for (java.util.Map<String, String> hc : hotspotClusters) {
                 if (climit++ >= 6) break;
                 String zone = hc.get("cluster");
                 if (zone == null) zone = "LOW ZONE";
                 boolean isHot = zone.startsWith("HOT");
                 boolean isMod = zone.startsWith("MOD");
                 String itemCls  = isHot ? "ci-hot" : (isMod ? "ci-mod" : "ci-low");
                 String dotCls   = isHot ? "cd-hot" : (isMod ? "cd-mod" : "cd-low");
                 String zoneCls  = isHot ? "cz-hot" : (isMod ? "cz-mod" : "cz-low");
                 String zoneLbl  = isHot ? "🔴 HOT" : (isMod ? "🟠 MOD" : "🟢 LOW");
            %>
              <div class="cluster-item <%= itemCls %>">
                <div class="cluster-dot <%= dotCls %>"></div>
                <div class="cluster-loc"><%= hc.get("location") %></div>
                <div class="cluster-zone <%= zoneCls %>"><%= zoneLbl %></div>
                <div class="cluster-cnt"><%= hc.get("count") %></div>
              </div>
            <% } %>
            </div>
            <div class="weka-note weka-note-purple">Locations grouped by offense frequency into 3 zones</div>
            <% } else { %>
            <p style="color:#9ca3af;font-size:13px;font-weight:700;margin-top:12px">No location data available for clustering.</p>
            <% } %>
          </div>

        </div>
      </div>
      <!-- END WEKA -->

    </div><!-- end content -->
  </main>
</div>

<script>
// ── Data from server ──
const monthLabels = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
const summonsData  = [<%= summonsArr[0] %>,<%= summonsArr[1] %>,<%= summonsArr[2] %>,<%= summonsArr[3] %>,<%= summonsArr[4] %>,<%= summonsArr[5] %>,<%= summonsArr[6] %>,<%= summonsArr[7] %>,<%= summonsArr[8] %>,<%= summonsArr[9] %>,<%= summonsArr[10] %>,<%= summonsArr[11] %>];
const vehicleData  = [<%= vehicleArr[0] %>,<%= vehicleArr[1] %>,<%= vehicleArr[2] %>,<%= vehicleArr[3] %>,<%= vehicleArr[4] %>,<%= vehicleArr[5] %>,<%= vehicleArr[6] %>,<%= vehicleArr[7] %>,<%= vehicleArr[8] %>,<%= vehicleArr[9] %>,<%= vehicleArr[10] %>,<%= vehicleArr[11] %>];
const miscData     = [<%= miscondArr[0] %>,<%= miscondArr[1] %>,<%= miscondArr[2] %>,<%= miscondArr[3] %>,<%= miscondArr[4] %>,<%= miscondArr[5] %>,<%= miscondArr[6] %>,<%= miscondArr[7] %>,<%= miscondArr[8] %>,<%= miscondArr[9] %>,<%= miscondArr[10] %>,<%= miscondArr[11] %>];
const collectData  = [<%= collectedArr[0] %>,<%= collectedArr[1] %>,<%= collectedArr[2] %>,<%= collectedArr[3] %>,<%= collectedArr[4] %>,<%= collectedArr[5] %>,<%= collectedArr[6] %>,<%= collectedArr[7] %>,<%= collectedArr[8] %>,<%= collectedArr[9] %>,<%= collectedArr[10] %>,<%= collectedArr[11] %>];
const pieLabels    = [<%= pieLabels %>];
const pieData      = [<%= pieData %>];

// ── Bar Chart: Monthly Summons ──
new Chart(document.getElementById('barChart'), {
  type: 'bar',
  data: {
    labels: monthLabels,
    datasets: [
      { label: 'Vehicle',    data: vehicleData, backgroundColor: '#3b82f6', borderRadius: 6 },
      { label: 'Misconduct', data: miscData,    backgroundColor: '#a855f7', borderRadius: 6 }
    ]
  },
  options: {
    responsive: true, maintainAspectRatio: false,
    plugins: { legend: { position: 'top' } },
    scales: {
      x: { stacked: true, grid: { display: false } },
      y: { stacked: true, beginAtZero: true, ticks: { stepSize: 1 } }
    }
  }
});

// ── Pie Chart: Offense Types ──
new Chart(document.getElementById('pieChart'), {
  type: 'doughnut',
  data: {
    labels: pieLabels,
    datasets: [{
      data: pieData,
      backgroundColor: ['#6f3cff','#3b82f6','#10b981','#f59e0b','#ef4444','#8b5cf6','#06b6d4','#ec4899','#84cc16','#f97316'],
      borderWidth: 2, borderColor: '#fff'
    }]
  },
  options: {
    responsive: true, maintainAspectRatio: false,
    plugins: { legend: { position: 'right', labels: { font: { size: 11 }, boxWidth: 14 } } }
  }
});

// ── Bar Chart: Monthly Collection ──
new Chart(document.getElementById('paymentChart'), {
  type: 'bar',
  data: {
    labels: monthLabels,
    datasets: [{
      label: 'Collected (RM)',
      data: collectData,
      backgroundColor: '#10b981',
      borderRadius: 6
    }]
  },
  options: {
    responsive: true, maintainAspectRatio: false,
    plugins: { legend: { display: false } },
    scales: {
      x: { grid: { display: false } },
      y: { beginAtZero: true, ticks: { callback: v => 'RM ' + v } }
    }
  }
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
