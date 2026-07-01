<%--
    Document   : patrol_view.jsp (Clerical - Single Patrol Staff Detail)
    Author     : SHAHRUL
--%>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@page import="model.ClericalStaff" %>
<%@page import="java.util.*" %>
<%
    ClericalStaff c = (ClericalStaff) session.getAttribute("clerical");
    if (c == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    Map<String, Object> info = (Map<String, Object>) request.getAttribute("patrolInfo");
    List<Map<String, Object>> summonsList = (List<Map<String, Object>>) request.getAttribute("summonsList");

    if (info == null || info.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/clerical/patrol/list");
        return;
    }

    String patrolId = (String) info.get("patrolStaffId");
    String patrolName = (String) info.get("patrolName");
    String email = (String) info.get("email");
    String phone = (String) info.get("phoneNumber");
    int total = info.get("totalSummons") != null ? (int) info.get("totalSummons") : 0;
    int today = info.get("todaySummons") != null ? (int) info.get("todaySummons") : 0;
    int vehicle = info.get("vehicleSummons") != null ? (int) info.get("vehicleSummons") : 0;
    int misconduct = info.get("misconductSummons") != null ? (int) info.get("misconductSummons") : 0;
    String lastActivity = (String) info.get("lastActivity");
    String initial = patrolName != null && patrolName.length() > 0 ? patrolName.substring(0, 1).toUpperCase() : "?";

    int pendingAppeals = 0;
    int pendingPayments = 0;
    int pendingVehicles = 0;
    try {
        pendingAppeals = new dao.AppealDAO().countPendingAppeals();
        try (java.sql.Connection _con = util.DBConnection.getConnection();
             java.sql.PreparedStatement _ps1 = _con.prepareStatement("SELECT COUNT(*) FROM payment WHERE status='PENDING_OFFICE'");
             java.sql.PreparedStatement _ps2 = _con.prepareStatement("SELECT COUNT(*) FROM vehicle WHERE status='PENDING'")) {
            try (java.sql.ResultSet _rs = _ps1.executeQuery()) {
                if (_rs.next()) pendingPayments = _rs.getInt(1);
            }
            try (java.sql.ResultSet _rs = _ps2.executeQuery()) {
                if (_rs.next()) pendingVehicles = _rs.getInt(1);
            }
        }
    } catch (Exception _ex) {
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= patrolName %> | Patrol Log</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        /* ===== RESET & BASE ===== */
        * {
            box-sizing: border-box;
        }
        body {
            margin: 0;
            background: #f5f6fb;
            font-family: system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif;
            overflow-x: hidden;
        }
        .app {
            min-height: 100vh;
            display: flex;
            width: 100%;
        }

        /* ===== SIDEBAR ===== */
        .sidebar {
            width: 260px;
            background: #f5f0ff;
            border-right: 1px solid #e4d9f7;
            position: fixed;
            inset: 0 auto 0 0;
            z-index: 30;
            transform: translateX(0);
            transition: transform 0.25s ease;
            display: flex;
            flex-direction: column;
            height: 100vh;
            overflow-y: auto;
        }
        .brand {
            display: flex;
            gap: 12px;
            align-items: center;
            padding: 24px 20px 18px;
            flex-shrink: 0;
        }
        .brand-badge {
            width: 40px;
            height: 40px;
            border-radius: 12px;
            background: #7c3aed;
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 900;
            font-size: 20px;
            box-shadow: 0 8px 24px rgba(124, 58, 237, 0.30);
            flex-shrink: 0;
        }
        .brand-title {
            font-weight: 900;
            color: #3b1c86;
            line-height: 1.1;
            font-size: 1rem;
        }
        .brand-sub {
            font-size: 0.75rem;
            color: #7c3aed;
            font-weight: 700;
        }

        .menu {
            padding: 10px 14px;
            display: flex;
            flex-direction: column;
            gap: 2px;
            flex: 1;
        }
        .menu a {
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 11px 14px;
            border-radius: 12px;
            color: #5b21b6;
            font-weight: 700;
            transition: 0.15s;
            font-size: 0.9rem;
        }
        .menu a:hover {
            background: #ede9fe;
            color: #4c1d95;
        }
        .menu a.active {
            background: #7c3aed;
            color: #fff;
            box-shadow: 0 4px 14px rgba(124, 58, 237, 0.25);
        }
        .menu a.active svg {
            opacity: 1;
        }
        .menu svg {
            opacity: 0.75;
            flex-shrink: 0;
        }
        .menu-label {
            font-size: 10px;
            font-weight: 900;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            color: #a78bfa;
            padding: 10px 14px 4px;
        }
        .notif-badge {
            margin-left: auto;
            background: #ef4444;
            color: #fff;
            font-size: 10px;
            font-weight: 950;
            padding: 2px 8px;
            border-radius: 999px;
            display: inline-block;
            flex-shrink: 0;
        }

        .sidebar-bottom {
            margin-top: auto;
            padding: 14px;
            border-top: 1px solid #e4d9f7;
            flex-shrink: 0;
        }
        .logout-btn {
            width: 100%;
            border: 0;
            background: #f5f0ff;
            color: #dc2626;
            font-weight: 900;
            padding: 12px 14px;
            border-radius: 12px;
            text-align: left;
            cursor: pointer;
            font-size: 0.9rem;
        }
        .logout-btn:hover {
            background: #fef2f2;
        }

        /* ===== OVERLAY ===== */
        .overlay {
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.45);
            z-index: 20;
            display: none;
        }
        .overlay.show {
            display: block;
        }

        /* ===== MAIN ===== */
        .main {
            flex: 1;
            min-width: 0;
            margin-left: 260px;
            display: flex;
            flex-direction: column;
            width: calc(100% - 260px);
        }
        .header {
            height: 64px;
            background: #fff;
            border-bottom: 1px solid #e5e7eb;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 16px;
            position: sticky;
            top: 0;
            z-index: 10;
            flex-shrink: 0;
        }
        .hamburger {
            border: 0;
            background: transparent;
            padding: 8px;
            border-radius: 10px;
            cursor: pointer;
        }
        .hamburger:hover {
            background: #f3f4f6;
        }
        .portal-title {
            font-weight: 800;
            color: #111827;
            font-size: 1.1rem;
        }
        .header-right {
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .userbox {
            display: flex;
            align-items: center;
            gap: 12px;
            border-left: 1px solid #f1f5f9;
            padding-left: 14px;
        }
        .usertext {
            display: none;
        }
        .avatar {
            width: 40px;
            height: 40px;
            border-radius: 999px;
            background: #ede9fe;
            color: #6f3cff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 900;
            flex-shrink: 0;
            font-size: 1rem;
        }

        .content {
            padding: 18px 16px 26px;
            flex: 1;
            max-width: 1100px;
            width: 100%;
            margin: 0 auto;
        }

        /* ===== SHARED ===== */
        .alert-success {
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            color: #15803d;
            border-radius: 14px;
            padding: 12px 16px;
            font-weight: 700;
            margin-bottom: 16px;
        }
        .alert-error {
            background: #fef2f2;
            border: 1px solid #fecaca;
            color: #dc2626;
            border-radius: 14px;
            padding: 12px 16px;
            font-weight: 700;
            margin-bottom: 16px;
        }

        .status-pill {
            font-size: 10px;
            font-weight: 950;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            padding: 5px 10px;
            border-radius: 999px;
            display: inline-block;
            white-space: nowrap;
        }
        .pill-unpaid {
            background: #fff7ed;
            color: #ea580c;
            border: 1px solid #ffedd5;
        }
        .pill-paid {
            background: #f0fdf4;
            color: #16a34a;
            border: 1px solid #dcfce7;
        }
        .pill-appealed {
            background: #eff6ff;
            color: #2563eb;
            border: 1px solid #dbeafe;
        }
        .pill-overdue {
            background: #fef2f2;
            color: #dc2626;
            border: 1px solid #fee2e2;
        }
        .pill-pending {
            background: #fff7ed;
            color: #ea580c;
            border: 1px solid #ffedd5;
        }

        .type-pill {
            font-size: 10px;
            font-weight: 950;
            text-transform: uppercase;
            padding: 5px 10px;
            border-radius: 999px;
            display: inline-block;
            white-space: nowrap;
        }
        .type-vehicle {
            background: #eff6ff;
            color: #2563eb;
            border: 1px solid #dbeafe;
        }
        .type-misconduct {
            background: #fff7ed;
            color: #ea580c;
            border: 1px solid #ffedd5;
        }

        .empty-state {
            text-align: center;
            padding: 48px 20px;
            color: #9ca3af;
        }
        .empty-state svg {
            opacity: 0.3;
            margin-bottom: 12px;
            display: block;
            margin-left: auto;
            margin-right: auto;
        }
        .empty-state p {
            font-weight: 700;
            font-size: 15px;
            margin: 0;
        }

        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 10px;
        }
        .page-header h1 {
            font-size: 22px;
            font-weight: 950;
            color: #111827;
            margin: 0;
        }
        .page-header p {
            font-size: 13px;
            color: #6b7280;
            font-weight: 700;
            margin: 4px 0 0;
        }

        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #f3e8ff;
            color: #6f3cff;
            font-weight: 900;
            padding: 10px 16px;
            border-radius: 14px;
            border: 0;
            text-decoration: none;
            font-size: 0.9rem;
        }
        .btn-back:hover {
            background: #ede9fe;
            color: #6f3cff;
        }
        .btn-purple {
            background: #6f3cff;
            border: 0;
            color: #fff;
            font-weight: 900;
            border-radius: 14px;
            padding: 10px 16px;
            box-shadow: 0 12px 26px rgba(111, 60, 255, 0.18);
            display: inline-flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
        }
        .btn-purple:hover {
            background: #5b21b6;
            color: #fff;
        }

        /* ===== TABLE CARD ===== */
        .table-card {
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 20px;
            box-shadow: 0 4px 12px rgba(17, 24, 39, 0.04);
            overflow: hidden;
            width: 100%;
        }
        .table-card table {
            width: 100%;
            border-collapse: collapse;
            min-width: 600px;
        }
        .table-card thead {
            background: #f9fafb;
        }
        .table-card th {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.12em;
            color: #6b7280;
            font-weight: 950;
            padding: 14px 16px;
            border-bottom: 1px solid #f1f5f9;
            text-align: left;
            white-space: nowrap;
        }
        .table-card td {
            padding: 14px 16px;
            border-bottom: 1px solid #f1f5f9;
            vertical-align: middle;
            font-size: 0.85rem;
        }
        .table-card tr:last-child td {
            border-bottom: 0;
        }
        .table-card tr:hover td {
            background: #fafafa;
        }

        .table-card-header {
            padding: 16px 20px;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 10px;
        }
        .table-card-header h3 {
            font-size: 16px;
            font-weight: 950;
            color: #111827;
            margin: 0;
        }
        .empty-mini {
            text-align: center;
            padding: 32px;
            color: #9ca3af;
            font-weight: 700;
            font-size: 13px;
        }

        /* ===== FILTER BAR ===== */
        .filter-bar {
            background: #fff;
            border-bottom: 1px solid #f1f5f9;
            padding: 12px 16px;
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }
        .filter-bar input,
        .filter-bar select {
            border: 1px solid #e5e7eb;
            border-radius: 10px;
            padding: 8px 12px;
            font-weight: 700;
            color: #374151;
            background: #f9fafb;
            font-size: 13px;
            outline: none;
            min-width: 0;
            flex: 1 1 140px;
        }
        .filter-bar input:focus,
        .filter-bar select:focus {
            border-color: #6f3cff;
            background: #fff;
        }
        .filter-bar input {
            flex: 2 1 200px;
        }

        /* ===== PROFILE BANNER ===== */
        .profile-banner {
            background: linear-gradient(135deg, #6f3cff, #4338ca);
            border-radius: 22px;
            padding: 24px;
            color: #fff;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 20px;
            flex-wrap: wrap;
        }
        .profile-avatar-lg {
            width: 64px;
            height: 64px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 950;
            font-size: 24px;
            flex-shrink: 0;
        }
        .profile-name {
            font-size: 20px;
            font-weight: 950;
            word-break: break-word;
        }
        .profile-meta {
            font-size: 13px;
            color: #e9d5ff;
            font-weight: 600;
            margin-top: 4px;
            word-break: break-word;
        }
        .active-badge {
            background: rgba(255, 255, 255, 0.2);
            color: #fff;
            font-size: 11px;
            font-weight: 950;
            padding: 4px 12px;
            border-radius: 999px;
            display: inline-block;
            margin-top: 8px;
            white-space: nowrap;
        }

        /* ===== STATS ROW — FIXED FOR RESPONSIVE ===== */
        .stats-row {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 14px;
            margin-bottom: 20px;
        }
        .stat-card {
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 18px;
            padding: 16px 12px;
            text-align: center;
            box-shadow: 0 4px 12px rgba(17, 24, 39, 0.04);
            min-width: 0;
            overflow: hidden;
        }
        .stat-value {
            font-size: 26px;
            font-weight: 950;
            color: #111827;
            line-height: 1.2;
            word-break: break-word;
            overflow-wrap: break-word;
        }
        .stat-label {
            font-size: 11px;
            font-weight: 900;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.10em;
            margin-top: 4px;
            word-break: break-word;
        }

        /* ── Responsive: Stats ── */
        @media (max-width: 992px) {
            .stats-row {
                grid-template-columns: repeat(2, 1fr);
                gap: 12px;
            }
            .stat-card {
                padding: 14px 10px;
            }
            .stat-value {
                font-size: 24px;
            }
        }
        @media (max-width: 576px) {
            .stats-row {
                gap: 10px;
            }
            .stat-card {
                padding: 12px 8px;
                border-radius: 14px;
            }
            .stat-value {
                font-size: 20px;
            }
            .stat-label {
                font-size: 9px;
                letter-spacing: 0.06em;
            }
        }
        @media (max-width: 400px) {
            .stats-row {
                gap: 8px;
            }
            .stat-card {
                padding: 10px 6px;
                border-radius: 12px;
            }
            .stat-value {
                font-size: 17px;
            }
            .stat-label {
                font-size: 8px;
            }
        }
        @media (max-width: 350px) {
            .stats-row {
                grid-template-columns: 1fr 1fr;
                gap: 6px;
            }
            .stat-card {
                padding: 8px 4px;
            }
            .stat-value {
                font-size: 15px;
            }
            .stat-label {
                font-size: 7px;
                letter-spacing: 0.04em;
            }
        }

        /* ===== SIDEBAR RESPONSIVE ===== */
        @media (max-width: 992px) {
            .main {
                margin-left: 0;
                width: 100%;
            }
            .sidebar {
                transform: translateX(-100%);
            }
            .sidebar.show {
                transform: translateX(0);
            }
            .usertext {
                display: block;
            }
            .profile-banner {
                flex-direction: column;
                text-align: center;
            }
            .content {
                padding: 14px 12px 20px;
            }
        }

        /* ===== TABLE RESPONSIVE ===== */
        @media (max-width: 768px) {
            .table-card table {
                min-width: 500px;
                font-size: 0.8rem;
            }
            .table-card th,
            .table-card td {
                padding: 10px 12px;
            }
            .table-card th {
                font-size: 10px;
            }
            .table-card td {
                font-size: 0.75rem;
            }
            .filter-bar input,
            .filter-bar select {
                font-size: 12px;
                padding: 6px 10px;
                flex: 1 1 120px;
            }
            .filter-bar {
                padding: 10px 12px;
                gap: 8px;
            }
            .table-card-header {
                padding: 12px 16px;
            }
            .table-card-header h3 {
                font-size: 14px;
            }
        }
        @media (max-width: 480px) {
            .table-card table {
                min-width: 420px;
                font-size: 0.7rem;
            }
            .table-card th,
            .table-card td {
                padding: 8px 10px;
            }
            .table-card th {
                font-size: 9px;
                letter-spacing: 0.06em;
            }
            .table-card td {
                font-size: 0.7rem;
            }
            .type-pill,
            .status-pill {
                font-size: 8px;
                padding: 3px 8px;
            }
            .filter-bar input,
            .filter-bar select {
                font-size: 11px;
                padding: 5px 8px;
                flex: 1 1 100px;
            }
            .filter-bar {
                padding: 8px 10px;
                gap: 6px;
            }
            .table-card-header {
                padding: 10px 12px;
            }
            .table-card-header h3 {
                font-size: 13px;
            }
        }

        /* ===== PROFILE BANNER RESPONSIVE ===== */
        @media (max-width: 576px) {
            .profile-banner {
                padding: 18px 16px;
                border-radius: 18px;
                gap: 14px;
            }
            .profile-avatar-lg {
                width: 52px;
                height: 52px;
                font-size: 20px;
            }
            .profile-name {
                font-size: 17px;
            }
            .profile-meta {
                font-size: 12px;
            }
            .active-badge {
                font-size: 10px;
                padding: 3px 10px;
            }
            .btn-back {
                font-size: 0.8rem;
                padding: 8px 14px;
            }
            .portal-title {
                font-size: 0.95rem;
            }
        }
        @media (max-width: 400px) {
            .profile-banner {
                padding: 14px 12px;
                border-radius: 14px;
                gap: 10px;
            }
            .profile-avatar-lg {
                width: 44px;
                height: 44px;
                font-size: 17px;
            }
            .profile-name {
                font-size: 15px;
            }
            .profile-meta {
                font-size: 11px;
            }
            .active-badge {
                font-size: 9px;
                padding: 2px 8px;
                margin-top: 4px;
            }
            .btn-back {
                font-size: 0.7rem;
                padding: 6px 12px;
                gap: 4px;
            }
            .portal-title {
                font-size: 0.85rem;
            }
            .header {
                padding: 0 12px;
                height: 56px;
            }
            .avatar {
                width: 34px;
                height: 34px;
                font-size: 0.8rem;
            }
        }

        /* ===== SIDEBAR SCROLL FIX ===== */
        .sidebar::-webkit-scrollbar {
            width: 4px;
        }
        .sidebar::-webkit-scrollbar-thumb {
            background: #c4b5e3;
            border-radius: 8px;
        }
        .sidebar::-webkit-scrollbar-track {
            background: transparent;
        }

        /* ===== UTILITY ===== */
        .d-lg-none {
            display: none !important;
        }
        @media (max-width: 992px) {
            .d-lg-none {
                display: inline-flex !important;
            }
        }
        .text-truncate-mobile {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 120px;
        }
        @media (max-width: 576px) {
            .text-truncate-mobile {
                max-width: 80px;
            }
        }
        @media (max-width: 400px) {
            .text-truncate-mobile {
                max-width: 60px;
            }
        }
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
                <a class="active" href="<%=request.getContextPath()%>/clerical/patrol/list">
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

        <!-- MAIN -->
        <main class="main">
            <header class="header">
                <button class="hamburger d-lg-none" onclick="openSidebar()" aria-label="Toggle sidebar">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none"><path d="M4 6h16M4 12h16M4 18h16" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
                </button>
                <div class="portal-title">CLERICAL Portal</div>
                <div class="userbox">
                    <div class="avatar"><%= c.getClericalName().substring(0, 1).toUpperCase() %></div>
                </div>
            </header>

            <div class="content">

                <a href="<%=request.getContextPath()%>/clerical/patrol/list" class="btn-back" style="margin-bottom:16px;display:inline-flex;">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M15 18l-6-6 6-6" stroke="currentColor" stroke-width="2"/></svg>
                    Back to Patrol List
                </a>

                <!-- Profile Banner -->
                <div class="profile-banner">
                    <div class="profile-avatar-lg"><%= initial %></div>
                    <div style="flex:1;min-width:0;">
                        <div class="profile-name"><%= patrolName %></div>
                        <div class="profile-meta"><%= patrolId %> • <%= email %> • <%= phone %></div>
                        <% if (today > 0) { %>
                        <span class="active-badge">🟢 Active Today — <%= today %> report<%= today != 1 ? "s" : "" %></span>
                        <% } else if (lastActivity != null) { %>
                        <span class="active-badge">Last active: <%= lastActivity.substring(0, 10) %></span>
                        <% } else { %>
                        <span class="active-badge">No activity yet</span>
                        <% } %>
                    </div>
                </div>

                <!-- Stats Row — FIXED: numbers now always visible -->
                <div class="stats-row">
                    <div class="stat-card">
                        <div class="stat-value" style="color:#6f3cff"><%= total %></div>
                        <div class="stat-label">Total Reports</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value" style="color:#2563eb"><%= today %></div>
                        <div class="stat-label">Today</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value" style="color:#2563eb"><%= vehicle %></div>
                        <div class="stat-label">Vehicle</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value" style="color:#ea580c"><%= misconduct %></div>
                        <div class="stat-label">Misconduct</div>
                    </div>
                </div>

                <!-- Summons Log Table -->
                <div class="table-card">
                    <div class="table-card-header">
                        <h3>📋 Summons Issued Log (<%= summonsList != null ? summonsList.size() : 0 %>)</h3>
                    </div>

                    <!-- Filter -->
                    <div class="filter-bar">
                        <input type="text" id="searchInput" placeholder="Search summons ID, offense or target…" oninput="filterTable()" />
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
                        </select>
                    </div>

                    <div style="overflow-x:auto;width:100%;">
                        <table id="logTable">
                            <thead>
                                <tr>
                                    <th>Summons ID</th>
                                    <th>Offense</th>
                                    <th>Type</th>
                                    <th>Target</th>
                                    <th>Location</th>
                                    <th>Amount</th>
                                    <th>Date</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody id="tableBody">
                                <% if (summonsList != null && !summonsList.isEmpty()) {
                                    for (Map<String, Object> sm : summonsList) {
                                        String smStatus = (String) sm.get("status");
                                        String smType = (String) sm.get("summonsType");
                                        String smPill = "PAID".equals(smStatus) ? "pill-paid" : "APPEALED".equals(smStatus) ? "pill-appealed" : "pill-unpaid";
                                %>
                                <tr data-type="<%= smType %>" data-status="<%= smStatus %>">
                                    <td style="font-weight:950;color:#111827;font-size:0.8rem;white-space:nowrap;"><%= sm.get("summonsId") %></td>
                                    <td style="font-weight:700;color:#374151;font-size:0.8rem;"><%= sm.get("offenseName") %></td>
                                    <td><span class="type-pill <%= "VEHICLE".equals(smType) ? "type-vehicle" : "type-misconduct" %>"><%= smType %></span></td>
                                    <td>
                                        <div style="font-weight:950;color:#111827;font-size:0.8rem;" class="text-truncate-mobile"><%= sm.get("targetName") %></div>
                                        <div style="font-size:0.65rem;color:#9ca3af;font-weight:700;" class="text-truncate-mobile"><%= sm.get("identifier") %></div>
                                    </td>
                                    <td style="font-size:0.75rem;color:#6b7280;font-weight:600;" class="text-truncate-mobile"><%= sm.get("location") %></td>
                                    <td style="font-weight:950;color:#111827;white-space:nowrap;">RM <%= String.format("%.2f", (double) sm.get("amount")) %></td>
                                    <td style="font-size:0.7rem;color:#6b7280;font-weight:700;white-space:nowrap;"><%= sm.get("summonsDate") %></td>
                                    <td><span class="status-pill <%= smPill %>"><%= smStatus %></span></td>
                                </tr>
                                <% } } else { %>
                                <tr><td colspan="8"><div class="empty-mini">No summons issued by this patrol staff yet.</div></td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <script>
        function filterTable() {
            const search = document.getElementById("searchInput").value.toLowerCase();
            const type = document.getElementById("filterType").value;
            const status = document.getElementById("filterStatus").value;
            const rows = document.querySelectorAll("#tableBody tr[data-type]");
            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                const rowType = row.getAttribute("data-type");
                const rowStatus = row.getAttribute("data-status");
                const m1 = text.includes(search);
                const m2 = !type || rowType === type;
                const m3 = !status || rowStatus === status;
                row.style.display = (m1 && m2 && m3) ? "" : "none";
            });
        }

        function openSidebar() {
            document.getElementById("sidebar").classList.add("show");
            document.getElementById("overlay").classList.add("show");
        }

        function closeSidebar() {
            document.getElementById("sidebar").classList.remove("show");
            document.getElementById("overlay").classList.remove("show");
        }

        // Close sidebar on Escape key
        document.addEventListener("keydown", function(e) {
            if (e.key === "Escape") closeSidebar();
        });
    </script>
</body>
</html>