<%-- receiptView.jsp — Official UMT Receipt (Bahagian Keselamatan) --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Student"%>
<%@page import="java.util.Map"%>
<%
    Student s = (Student) session.getAttribute("student");
    if (s == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    Map<String, String> r = (Map<String, String>) request.getAttribute("receipt");
    if (r == null) {
        response.sendRedirect(request.getContextPath() + "/student/payment/receipts");
        return;
    }
    boolean isOnline = "ONLINE".equals(r.get("paymentMethod"));

    // Mask card number if online
    String maskedCard = "—";
    if (isOnline && r.get("bankCardNo") != null && r.get("bankCardNo").length() >= 4) {
        String cardNo = r.get("bankCardNo");
        maskedCard = "**** **** **** " + cardNo.substring(cardNo.length() - 4);
    }

    // Receipt serial number for display
    String serialNo = "UMT/BK/" + java.time.Year.now().getValue() + "/" + r.get("paymentId");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Official Receipt <%= r.get("paymentId") %> | UMT</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    /* ── Screen styles ── */
    body{margin:0;background:#f1f5f9;font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif}

    .screen-header{
      background:#fff;border-bottom:1px solid #e5e7eb;
      padding:14px 28px;display:flex;align-items:center;
      justify-content:space-between;gap:16px;
    }
    .btn-back{display:inline-flex;align-items:center;gap:8px;background:#f3e8ff;color:#6f3cff;font-weight:900;padding:9px 16px;border-radius:12px;border:0;text-decoration:none;font-size:13px}
    .btn-back:hover{background:#ede9fe;color:#6f3cff}
    .btn-print{background:#6f3cff;color:#fff;border:0;border-radius:12px;padding:9px 20px;font-weight:900;font-size:13px;cursor:pointer}
    .btn-print:hover{background:#5b21b6}

    .page-wrap{max-width:780px;margin:30px auto 60px;padding:0 16px}

    /* ── The actual receipt (also used for print) ── */
    .receipt{
      background:#fff;
      border:1px solid #d1d5db;
      border-radius:0;
      box-shadow:0 8px 30px rgba(0,0,0,.10);
      overflow:hidden;
      font-family:"Times New Roman",Times,serif;
    }

    /* UMT blue header */
    .rec-header{
      background:#00338D;
      padding:0;
      color:#fff;
    }
    .rec-header-inner{
      display:flex;align-items:center;gap:20px;
      padding:20px 32px;
    }
    .umt-logo-placeholder{
      width:72px;height:72px;border-radius:50%;
      background:#fff;display:flex;align-items:center;
      justify-content:center;flex-shrink:0;
      border:3px solid #fbbf24;
    }
    .umt-logo-placeholder span{
      font-size:11px;font-weight:900;color:#00338D;
      text-align:center;line-height:1.2;letter-spacing:-.3px;
    }
    .rec-header-text{flex:1}
    .rec-header-text h1{
      margin:0;font-size:17px;font-weight:900;
      font-family:Arial,sans-serif;letter-spacing:.3px;
    }
    .rec-header-text p{
      margin:3px 0 0;font-size:12px;color:#bfdbfe;
      font-family:Arial,sans-serif;font-weight:600;
    }
    .rec-serial{
      text-align:right;flex-shrink:0;
      font-family:Arial,sans-serif;
    }
    .rec-serial .label{font-size:10px;color:#93c5fd;font-weight:700;text-transform:uppercase;letter-spacing:.1em}
    .rec-serial .value{font-size:14px;font-weight:900;margin-top:2px}

    /* Gold divider strip */
    .gold-strip{height:5px;background:linear-gradient(90deg,#fbbf24,#f59e0b,#fbbf24)}

    /* Receipt title bar */
    .rec-title{
      background:#f8fafc;border-bottom:2px solid #e2e8f0;
      padding:14px 32px;text-align:center;
    }
    .rec-title h2{
      margin:0;font-size:16px;font-weight:900;
      color:#00338D;letter-spacing:2px;
      text-transform:uppercase;font-family:Arial,sans-serif;
    }
    .rec-title p{margin:4px 0 0;font-size:12px;color:#64748b;font-family:Arial,sans-serif}

    /* Paid stamp */
    .paid-stamp{
      display:inline-block;
      border:3px solid #16a34a;color:#16a34a;
      font-size:13px;font-weight:900;
      padding:3px 14px;border-radius:4px;
      letter-spacing:3px;text-transform:uppercase;
      transform:rotate(-8deg);margin-left:12px;
      vertical-align:middle;font-family:Arial,sans-serif;
    }

    /* Body sections */
    .rec-body{padding:24px 32px}

    .rec-section{margin-bottom:22px}
    .rec-section-title{
      font-size:11px;font-weight:900;text-transform:uppercase;
      letter-spacing:.15em;color:#64748b;
      border-bottom:1px solid #e2e8f0;padding-bottom:6px;
      margin-bottom:12px;font-family:Arial,sans-serif;
    }
    .rec-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px}
    .rec-field .field-label{
      font-size:10px;font-weight:700;color:#94a3b8;
      text-transform:uppercase;letter-spacing:.1em;
      font-family:Arial,sans-serif;
    }
    .rec-field .field-value{
      font-size:14px;font-weight:700;color:#1e293b;
      margin-top:2px;font-family:"Times New Roman",Times,serif;
    }
    .rec-field .field-value.bold{font-weight:900}

    /* Amount box */
    .amount-box{
      background:#f0fdf4;border:2px solid #86efac;
      border-radius:8px;padding:18px 24px;
      display:flex;justify-content:space-between;align-items:center;
      margin:18px 0;
    }
    .amount-label{font-size:13px;font-weight:700;color:#15803d;font-family:Arial,sans-serif}
    .amount-value{font-size:30px;font-weight:900;color:#15803d;font-family:Arial,sans-serif}

    /* Signature block */
    .sig-row{
      display:flex;justify-content:space-between;
      margin-top:32px;padding-top:18px;
      border-top:1px dashed #cbd5e1;
    }
    .sig-block{text-align:center;width:180px}
    .sig-line{border-bottom:1px solid #1e293b;margin-bottom:6px;height:40px}
    .sig-label{font-size:11px;color:#64748b;font-family:Arial,sans-serif}
    .sig-name {font-size:12px;font-weight:900;color:#1e293b;font-family:Arial,sans-serif}

    /* Footer */
    .rec-footer{
      background:#00338D;color:#bfdbfe;
      padding:14px 32px;text-align:center;
      font-size:11px;font-family:Arial,sans-serif;
    }
    .rec-footer p{margin:2px 0}
    .rec-footer .warning{color:#fbbf24;margin-top:6px;font-size:10px}

    /* ── Print styles ── */
    @media print {
      body{background:#fff}
      .screen-header{display:none!important}
      .page-wrap{margin:0;padding:0;max-width:100%}
      .receipt{box-shadow:none;border:none}
      @page{margin:1cm}
    }

    @media(max-width:600px){
      .rec-header-inner{flex-wrap:wrap}
      .rec-serial{text-align:left;width:100%}
      .rec-grid{grid-template-columns:1fr}
      .sig-row{flex-direction:column;gap:24px;align-items:center}
    }
  </style>
</head>
<body>

  <!-- Screen-only top bar -->
  <div class="screen-header" id="screenBar">
    <a href="<%=request.getContextPath()%>/student/payment/receipts" class="btn-back">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
        <path d="M15 18l-6-6 6-6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
      </svg>
      My Receipts
    </a>
    <div style="font-weight:900;color:#111827;font-size:15px">Official Payment Receipt</div>
    <button class="btn-print" onclick="window.print()">
      🖨️ Print / Save PDF
    </button>
  </div>

  <div class="page-wrap">
    <div class="receipt">

      <!-- ══ UMT Header ══ -->
      <div class="rec-header">
        <div class="rec-header-inner">

          <!-- Logo placeholder (replace <span> with <img> if you have the UMT logo) -->
          <div class="umt-logo-placeholder">
            <span><img src="<%=request.getContextPath()%>/images/logoumt.png"
                      width="66" height="66" alt="UMT Logo" style="border-radius:50%"></span>
          </div>

          <div class="rec-header-text">
            <h1>UNIVERSITI MALAYSIA TERENGGANU</h1>
            <p>Bahagian Keselamatan | Smart Campus Disciplinary System</p>
            <p>21030 Kuala Nerus, Terengganu Darul Iman, Malaysia</p>
          </div>

          <div class="rec-serial">
            <div class="label">Receipt No.</div>
            <div class="value"><%= serialNo %></div>
          </div>
        </div>
      </div>

      <!-- Gold strip -->
      <div class="gold-strip"></div>

      <!-- Title -->
      <div class="rec-title">
        <h2>
          Resit Rasmi Pembayaran &nbsp;/&nbsp; Official Payment Receipt
          <span class="paid-stamp">PAID</span>
        </h2>
        <p>Sila simpan resit ini sebagai rekod pembayaran anda. / Please retain this receipt as proof of payment.</p>
      </div>

      <!-- Body -->
      <div class="rec-body">

        <!-- Amount -->
        <div class="amount-box">
          <div>
            <div class="amount-label">Jumlah Dibayar / Amount Paid</div>
            <div style="font-size:12px;color:#15803d;font-weight:700;margin-top:2px">
              <%= r.get("summonsId") %> — <%= r.get("offenseName") %>
            </div>
          </div>
          <div class="amount-value">
            RM <%= String.format("%.2f", Double.parseDouble(r.get("paymentAmount"))) %>
          </div>
        </div>

        <!-- Student Info -->
        <div class="rec-section">
          <div class="rec-section-title">Maklumat Pelajar / Student Information</div>
          <div class="rec-grid">
            <div class="rec-field">
              <div class="field-label">Nama Pelajar / Student Name</div>
              <div class="field-value bold"><%= r.get("studentName") %></div>
            </div>
            <div class="rec-field">
              <div class="field-label">No. Matrik / Matric No.</div>
              <div class="field-value bold"><%= r.get("matricNo") %></div>
            </div>
            <div class="rec-field">
              <div class="field-label">Fakulti / Faculty</div>
              <div class="field-value"><%= r.get("faculty") != null ? r.get("faculty") : "—" %></div>
            </div>
            <div class="rec-field">
              <div class="field-label">E-mel / Email</div>
              <div class="field-value"><%= r.get("email") != null ? r.get("email") : "—" %></div>
            </div>
          </div>
        </div>

        <!-- Summons Info -->
        <div class="rec-section">
          <div class="rec-section-title">Maklumat Saman / Summons Details</div>
          <div class="rec-grid">
            <div class="rec-field">
              <div class="field-label">ID Saman / Summons ID</div>
              <div class="field-value bold"><%= r.get("summonsId") %></div>
            </div>
            <div class="rec-field">
              <div class="field-label">Jenis Saman / Summons Type</div>
              <div class="field-value"><%= r.get("summonsType") %></div>
            </div>
            <div class="rec-field">
              <div class="field-label">Kesalahan / Offense</div>
              <div class="field-value"><%= r.get("offenseName") %></div>
            </div>
            <div class="rec-field">
              <div class="field-label">Lokasi / Location</div>
              <div class="field-value"><%= r.get("location") != null ? r.get("location") : "—" %></div>
            </div>
            <div class="rec-field">
              <div class="field-label">Tarikh Saman / Summons Date</div>
              <div class="field-value"><%= r.get("summonsDate") %></div>
            </div>
          </div>
        </div>

        <!-- Payment Info -->
        <div class="rec-section">
          <div class="rec-section-title">Maklumat Pembayaran / Payment Details</div>
          <div class="rec-grid">
            <div class="rec-field">
              <div class="field-label">ID Pembayaran / Payment ID</div>
              <div class="field-value bold"><%= r.get("paymentId") %></div>
            </div>
            <div class="rec-field">
              <div class="field-label">Tarikh Bayar / Payment Date</div>
              <div class="field-value bold"><%= r.get("paymentDate") %></div>
            </div>
            <div class="rec-field">
              <div class="field-label">Kaedah / Method</div>
              <div class="field-value">
                <%= isOnline ? "Dalam Talian (Online)" : "Bayaran Di Kaunter (Office)" %>
              </div>
            </div>
            <% if (isOnline) { %>
            <div class="rec-field">
              <div class="field-label">Kad Digunakan / Card Used</div>
              <div class="field-value"><%= maskedCard %></div>
            </div>
            <% } %>
            <div class="rec-field">
              <div class="field-label">Status</div>
              <div class="field-value bold" style="color:#16a34a">✓ TELAH DIBAYAR / PAID</div>
            </div>
          </div>
        </div>

        <!-- Signature block -->
        <div class="sig-row">
          <div class="sig-block">
            <div class="sig-line"></div>
            <div class="sig-name">Pelajar / Student</div>
            <div class="sig-label"><%= r.get("studentName") %></div>
            <div class="sig-label"><%= r.get("matricNo") %></div>
          </div>
          <div class="sig-block">
            <div class="sig-line"></div>
            <div class="sig-name">Pegawai Keselamatan</div>
            <div class="sig-label">Bahagian Keselamatan UMT</div>
            <div class="sig-label">Cop Rasmi / Official Stamp</div>
          </div>
        </div>

      </div><!-- end rec-body -->

      <!-- Footer -->
      <div class="rec-footer">
        <p><b>Bahagian Keselamatan, Universiti Malaysia Terengganu (UMT)</b></p>
        <p>Tel: 09-668 3000 &nbsp;|&nbsp; Faks: 09-668 3001 &nbsp;|&nbsp; keselamatan@umt.edu.my</p>
        <p>21030 Kuala Nerus, Terengganu Darul Iman, Malaysia</p>
        <p class="warning">
          ⚠️ Resit ini dijana secara automatik oleh sistem. /
          This receipt is system-generated by Smart Campus Disciplinary System.
        </p>
      </div>

    </div><!-- end .receipt -->
  </div><!-- end .page-wrap -->

</body>
</html>