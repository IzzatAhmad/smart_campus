<%-- 
    Document   : register
    Created on : 1 Jan 2026, 4:14:57 am
    Author     : SHAHRUL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Register | Smart Campus</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

  <style>
    body{
      min-height:100vh;
      background:#f3f0ff;
      display:flex;
      align-items:center;
      justify-content:center;
      padding:24px;
      font-family: system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif;
    }
    .auth-card{
      width:100%;
      max-width:900px;
      border-radius:2.5rem;
      border:1px solid #eee7ff;
      box-shadow:0 24px 60px rgba(88, 53, 201, .15);
      overflow:hidden;
      background:#fff;
    }
    .brand-dot{
      width:44px;height:44px;
      display:flex;
      align-items:center;
      justify-content:center;
    }

    .muted{color:#6b7280;}
    .label{font-weight:700; font-size:.9rem; color:#374151; margin-left:4px;}
    .inp{
      border:1px solid transparent;
      background:#f4f6f8;
      border-radius:18px;
      padding:12px 14px 12px 44px;
      transition:.2s;
    }
    .inp:focus{
      background:#fff;
      border-color:#efe6ff;
      box-shadow:0 0 0 .25rem rgba(111,60,255,.12);
    }
    .sel{ padding-left:44px; }
    .icon{
      position:absolute; left:14px; top:50%;
      transform:translateY(-50%);
      opacity:.45;
    }
    .btn-purple{
      background:#6f3cff;
      border:0;
      border-radius:18px;
      padding:14px;
      font-weight:800;
      box-shadow:0 18px 40px rgba(111,60,255,.18);
    }
    .btn-purple:hover{background:#5f2df0;}
    .topbar{
      display:grid;
      grid-template-columns: 1fr auto 1fr;
      align-items:center;
      margin-bottom:18px;
    }
    .topbar .back-link{ justify-self:start; }
    .topbar .logo-umt{
      justify-self:center;
      width:clamp(48px, 14vw, 64px);
      height:clamp(48px, 14vw, 64px);
      object-fit:contain;
    }
  </style>
</head>

<body>
<%
  String err = (String) request.getAttribute("error");

  // keep user input after error
  String nameVal   = request.getParameter("name") != null ? request.getParameter("name") : "";
  String matricVal = request.getParameter("matric") != null ? request.getParameter("matric") : "";
  String emailVal  = request.getParameter("email") != null ? request.getParameter("email") : "";
  String phoneVal  = request.getParameter("phone") != null ? request.getParameter("phone") : "";
  String facVal    = request.getParameter("faculty") != null ? request.getParameter("faculty") : "";
%>

  <div class="auth-card">
    <div class="p-4 p-md-5">

      <div class="topbar">
        <a href="index.html" class="back-link text-decoration-none text-secondary">
          <!-- ArrowLeft icon -->
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
            <path d="M15 18l-6-6 6-6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </a>
        <img src="<%=request.getContextPath()%>/images/logoumt.png"
             alt="UMT" class="logo-umt"/>
      </div>

      <div class="text-center mb-4">
        <h2 class="fw-bold mb-1">Student Registration</h2>
        <div class="muted">Create your student account to manage summons</div>
      </div>

      <% if (err != null) { %>
        <div class="alert alert-danger rounded-4"><%= err %></div>
      <% } %>

      <form method="post" action="<%=request.getContextPath()%>/register">

        <div class="row g-4">

          <div class="col-12">
            <div class="label mb-2">Full Name</div>
            <div class="position-relative">
              <span class="icon">
                <!-- UserCircle icon -->
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                  <path d="M20 21a8 8 0 10-16 0" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                  <path d="M12 12a4 4 0 100-8 4 4 0 000 8z" stroke="currentColor" stroke-width="2"/>
                </svg>
              </span>
              <input class="form-control inp" name="name" value="<%=nameVal%>" placeholder="e.g. Ahmad Zaki Bin Yusof" required>
            </div>
          </div>

          <div class="col-12 col-md-6">
            <div class="label mb-2">Matric Number</div>
            <div class="position-relative">
              <span class="icon">
                <!-- Hash icon -->
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                  <path d="M4 9h16M4 15h16M10 3L8 21M16 3l-2 18" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                </svg>
              </span>
              <input class="form-control inp" name="matric" value="<%=matricVal%>" placeholder="e.g. S70611" required style="text-transform:uppercase;">
            </div>
          </div>

          <div class="col-12 col-md-6">
            <div class="label mb-2">Email Address</div>
            <div class="position-relative">
              <span class="icon">
                <!-- Mail icon -->
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                  <path d="M4 6h16v12H4V6z" stroke="currentColor" stroke-width="2" stroke-linejoin="round"/>
                  <path d="M4 7l8 6 8-6" stroke="currentColor" stroke-width="2" stroke-linejoin="round"/>
                </svg>
              </span>
              <input class="form-control inp" type="email" name="email" value="<%=emailVal%>" placeholder="matric@ocean.umt.edu.my" required>
            </div>
          </div>

          <div class="col-12 col-md-6">
            <div class="label mb-2">Phone Number</div>
            <div class="position-relative">
              <span class="icon">
                <!-- Phone icon -->
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                  <path d="M22 16.92v3a2 2 0 01-2.18 2 19.8 19.8 0 01-8.63-3.07A19.5 19.5 0 013.15 12.8 19.8 19.8 0 01.08 4.18 2 2 0 012.06 2h3a2 2 0 012 1.72c.12.86.3 1.7.54 2.5a2 2 0 01-.45 2.11L6.09 9.91a16 16 0 006 6l1.58-1.6a2 2 0 012.11-.45c.8.24 1.64.42 2.5.54A2 2 0 0122 16.92z"
                        stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </span>
              <input class="form-control inp" name="phone" value="<%=phoneVal%>" placeholder="+6012-3456789" required>
            </div>
          </div>

          <div class="col-12 col-md-6">
            <div class="label mb-2">Faculty</div>
            <div class="position-relative">
              <span class="icon">
                <!-- Building2 icon -->
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                  <path d="M3 21V7l9-4 9 4v14" stroke="currentColor" stroke-width="2" stroke-linejoin="round"/>
                  <path d="M9 21v-8h6v8" stroke="currentColor" stroke-width="2" stroke-linejoin="round"/>
                </svg>
              </span>
              <select class="form-select inp sel" name="faculty" required>
                <option value="" <%= facVal.isEmpty() ? "selected" : "" %> disabled>Select your faculty</option>
                <option value="FSKM" <%= "FSKM".equals(facVal) ? "selected" : "" %>>Faculty of Science Computer And Mathematics (FSKM)</option>
                <option value="FTKK" <%= "FTKK".equals(facVal) ? "selected" : "" %>>Faculty of Ocean Engineering Technology (FTKK)</option>
                <option value="FSSM"  <%= "FSSM".equals(facVal)  ? "selected" : "" %>>Faculty of Science and Marine Environment (FSSM)</option>
                <option value="FSPA"  <%= "FSPA".equals(facVal)  ? "selected" : "" %>>Faculty of Fisheries and Aquaculture Science (FSPA)</option>
                <option value="FSMA"  <%= "FSMA".equals(facVal)  ? "selected" : "" %>>Faculty of Food Science and Agrotechnology (FSMA)</option>
                <option value="FPEPS"  <%= "FPEPS".equals(facVal)  ? "selected" : "" %>>Faculty of Business, Economics and Social Development (FPEPS)</option>
                <option value="FPM"  <%= "FPM".equals(facVal)  ? "selected" : "" %>>Faculty of Maritime Studies (FPM)</option>
                <option value="PASTEM"  <%= "PASTEM".equals(facVal)  ? "selected" : "" %>>Foundation of STEM (PASTEM)</option>
              </select>
            </div>
          </div>

          <div class="col-12 col-md-6">
            <div class="label mb-2">Password</div>
            <div class="position-relative">
              <span class="icon">
                <!-- Lock icon -->
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                  <path d="M7 11V8a5 5 0 0110 0v3" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                  <path d="M6 11h12v10H6V11z" stroke="currentColor" stroke-width="2" stroke-linejoin="round"/>
                </svg>
              </span>
              <input class="form-control inp" type="password" name="password" placeholder="••••••••" required>
            </div>
          </div>

          <div class="col-12 col-md-6">
            <div class="label mb-2">Confirm Password</div>
            <div class="position-relative">
              <span class="icon">
                <!-- Lock icon -->
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                  <path d="M7 11V8a5 5 0 0110 0v3" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                  <path d="M6 11h12v10H6V11z" stroke="currentColor" stroke-width="2" stroke-linejoin="round"/>
                </svg>
              </span>
              <input class="form-control inp" type="password" name="confirmPassword" placeholder="••••••••" required>
            </div>
          </div>

          <div class="col-12">
            <button class="btn btn-purple text-white w-100 mt-1" type="submit">
              Register Account
            </button>

            <div class="text-center mt-4 muted">
              Already have an account?
              <a class="text-decoration-none" style="color:#6f3cff;font-weight:900"
                 href="<%=request.getContextPath()%>/login">Login Now</a>
            </div>
          </div>

        </div>
      </form>

    </div>
  </div>
</body>
</html>
