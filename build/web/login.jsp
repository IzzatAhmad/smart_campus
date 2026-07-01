<%-- 
    Document   : login
    Created on : 1 Jan 2026, 4:14:18 am
    Author     : SHAHRUL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login | Smart Campus</title>
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
      max-width:520px;
      border-radius:2.5rem;
      border:1px solid #eee7ff;
      box-shadow:0 24px 60px rgba(88, 53, 201, .15);
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
      padding:12px 44px 12px 44px;
      transition:.2s;
    }
    .inp:focus{
      background:#fff;
      border-color:#efe6ff;
      box-shadow:0 0 0 .25rem rgba(111,60,255,.12);
    }
    .icon{
      position:absolute; left:14px; top:50%;
      transform:translateY(-50%);
      opacity:.45;
      pointer-events:none;
    }
    .eye-btn{
      position:absolute;
      right:14px;
      top:50%;
      transform:translateY(-50%);
      background:none;
      border:none;
      cursor:pointer;
      opacity:.55;
      padding:6px;
      border-radius:12px;
    }
    .eye-btn:hover{
      background:#eef0f6;
      opacity:1;
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
      display:flex; align-items:center; justify-content:space-between;
      margin-bottom:18px;
    }
    .ghost{width:44px;height:44px;opacity:0;}

    /* Role tabs */
    .role-wrap{
      display:grid;
      grid-template-columns:repeat(3,1fr);
      gap:8px;
      padding:8px;
      background:#f6f7fb;
      border:1px solid #eef0f6;
      border-radius:18px;
      margin-bottom:18px;
    }
    .role-btn{
      border:0;
      background:transparent;
      padding:10px 12px;
      border-radius:14px;
      font-weight:800;
      font-size:.85rem;
      color:#9ca3af;
      cursor:pointer;
    }
    .role-btn.active{
      background:#fff;
      color:#6f3cff;
      box-shadow:0 8px 18px rgba(17,24,39,.08);
      border:1px solid rgba(0,0,0,.05);
    }
  </style>
</head>

<body>
<%
  String err = (String) request.getAttribute("error");
%>

<div class="auth-card p-4 p-md-5">

  <!-- Top -->
  <div class="topbar">
    <a href="<%=request.getContextPath()%>/" class="text-decoration-none text-secondary">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
        <path d="M15 18l-6-6 6-6" stroke="currentColor" stroke-width="2"/>
      </svg>
    </a>
    <div class="ghost"></div>
  </div>

  <!-- UMT Logo (centred, larger) -->
  <div class="text-center mb-3">
    <img src="<%=request.getContextPath()%>/images/logoumt.png"
         alt="UMT Logo"
         style="width:120px; height:120px; object-fit:contain; filter:drop-shadow(0 4px 12px rgba(111,60,255,.15));"/>
  </div>

  <!-- Title -->
  <div class="text-center mb-4">
    <h2 class="fw-bold mb-1" id="loginTitle">Student Login</h2>
    <div class="muted" id="loginSub">Access the student portal</div>
  </div>

  <% if (err != null) { %>
    <div class="alert alert-danger rounded-4"><%= err %></div>
  <% } %>

  <!-- Role selector -->
  <div class="role-wrap">
    <button type="button" class="role-btn active" data-role="STUDENT">Student</button>
    <button type="button" class="role-btn" data-role="PATROL">Patrol</button>
    <button type="button" class="role-btn" data-role="CLERICAL">Clerical</button>
  </div>

  <!-- Login form -->
  <form id="loginForm" method="post" action="<%=request.getContextPath()%>/login" class="d-grid gap-3">
    <input type="hidden" name="role" id="roleInput" value="STUDENT">

    <!-- Email -->
    <div>
      <div class="label mb-2">Email Address</div>
      <div class="position-relative">
        <span class="icon">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
            <path d="M4 6h16v12H4V6z" stroke="currentColor" stroke-width="2"/>
            <path d="M4 7l8 6 8-6" stroke="currentColor" stroke-width="2"/>
          </svg>
        </span>
        <input class="form-control inp" type="email" name="email"
               placeholder="matric@umt.edu.my" required>
      </div>
    </div>

    <!-- Password -->
    <div>
      <div class="label mb-2">Password</div>
      <div class="position-relative">
        <span class="icon">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
            <path d="M7 11V8a5 5 0 0110 0v3" stroke="currentColor" stroke-width="2"/>
            <path d="M6 11h12v10H6V11z" stroke="currentColor" stroke-width="2"/>
          </svg>
        </span>

        <input id="passwordInput" class="form-control inp"
               type="password" name="password"
               placeholder="••••••••" required>

        <button type="button" class="eye-btn" id="togglePassBtn" aria-label="Show password">
          <svg id="eyeIcon" width="18" height="18" viewBox="0 0 24 24" fill="none">
            <path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7S1 12 1 12z"
                  stroke="currentColor" stroke-width="2"/>
            <circle cx="12" cy="12" r="3"
                    stroke="currentColor" stroke-width="2"/>
          </svg>
        </button>
      </div>
    </div>

    <button type="submit" class="btn btn-purple text-white mt-2">
      Sign In
    </button>
  </form>

  <!-- Register (ONLY STUDENT) -->
  <div class="text-center mt-4 muted" id="registerLine">
    Don’t have an account?
    <a href="<%=request.getContextPath()%>/register"
       style="color:#6f3cff;font-weight:900;text-decoration:none">
      Register Now
    </a>
  </div>

</div>

<script>
  // ===== Role selector + form action switch =====
  const roleBtns = document.querySelectorAll(".role-btn");
  const roleInput = document.getElementById("roleInput");
  const title = document.getElementById("loginTitle");
  const sub = document.getElementById("loginSub");
  const registerLine = document.getElementById("registerLine");
  const loginForm = document.getElementById("loginForm");

  function setRole(role){
    roleInput.value = role;

    if(role === "STUDENT"){
      title.textContent = "Student Login";
      sub.textContent = "Access the student portal";
      registerLine.style.display = "block";
      loginForm.action = "<%=request.getContextPath()%>/login"; // StudentLoginServlet
    } else if(role === "PATROL"){
      title.textContent = "Patrol Staff Login";
      sub.textContent = "Access the patrol staff portal";
      registerLine.style.display = "none";
      loginForm.action = "<%=request.getContextPath()%>/patrol/login"; // PatrolLoginServlet
    } else {
      title.textContent = "Clerical Staff Login";
      sub.textContent = "Access the clerical staff portal";
      registerLine.style.display = "none";
      loginForm.action = "<%=request.getContextPath()%>/clerical/login"; // ClericalLoginServlet
    }
  }

  roleBtns.forEach(btn => {
    btn.addEventListener("click", () => {
      roleBtns.forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      setRole(btn.dataset.role);
    });
  });

  // ===== Show / Hide password =====
  const toggleBtn = document.getElementById("togglePassBtn");
  toggleBtn.addEventListener("click", () => {
    const input = document.getElementById("passwordInput");
    const icon = document.getElementById("eyeIcon");

    if (input.type === "password") {
      input.type = "text";
      icon.innerHTML = `
        <path d="M3 3l18 18" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
        <path d="M1 12s4-7 11-7c2.2 0 4.1.6 5.7 1.5" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
        <path d="M23 12s-4 7-11 7c-2.2 0-4.1-.6-5.7-1.5" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
      `;
    } else {
      input.type = "password";
      icon.innerHTML = `
        <path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7S1 12 1 12z"
              stroke="currentColor" stroke-width="2"/>
        <circle cx="12" cy="12" r="3"
                stroke="currentColor" stroke-width="2"/>
      `;
    }
  });

  // default
  setRole("STUDENT");
</script>

</body>
</html>
