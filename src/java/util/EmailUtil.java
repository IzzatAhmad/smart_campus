/*
 * EmailUtil.java
 * Place in: src/java/util/EmailUtil.java
 *
 * SETUP REQUIRED:
 * 1. Add JavaMail JAR to your project:
 *    - In NetBeans: right-click project → Properties → Libraries → Add JAR
 *    - Download: https://mvnrepository.com/artifact/com.sun.mail/javax.mail
 *      (file: javax.mail-1.6.2.jar)
 *
 * 2. Go to your Gmail account:
 *    - Enable 2-Step Verification
 *    - Go to: Google Account → Security → App Passwords
 *    - Create an App Password for "Mail" → copy the 16-char password
 *    - Paste it into SENDER_PASSWORD below (NOT your real Gmail password)
 *
 * 3. Replace SENDER_EMAIL with your Gmail address.
 */
package util;

import java.io.UnsupportedEncodingException;
import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;

public class EmailUtil {

    // ── CONFIG — change these two values ──
    private static final String SENDER_EMAIL    = "aimanmokhtar296@gmail.com";   // your Gmail
    private static final String SENDER_PASSWORD = "crqi tqyc cgdk pukh";  // App Password (16 chars)

    // ── Send a payment receipt email to the student ──
    public static void sendPaymentReceipt(
            String toEmail,
            String studentName,
            String matricNo,
            String paymentId,
            String summonsId,
            String offenseName,
            String summonsType,
            String location,
            double amount,
            String paymentDate,
            String paymentMethod,
            String contextPath   // e.g. "/SmartCampus" — used to build receipt link
    ) throws MessagingException, UnsupportedEncodingException {

        Properties props = new Properties();
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host",            "smtp.gmail.com");
        props.put("mail.smtp.port",            "587");
        props.put("mail.smtp.ssl.trust",       "smtp.gmail.com");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });

        Message msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress(SENDER_EMAIL, "Bahagian Keselamatan UMT"));
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        msg.setSubject("Payment Receipt — " + paymentId + " | Smart Campus UMT");

        String methodLabel  = "ONLINE".equals(paymentMethod) ? "Online Payment" : "Office Payment";
        String amountFormatted = String.format("RM %.2f", amount);

        // ── HTML email body styled like an official UMT receipt ──
        String html =
            "<!DOCTYPE html><html><head><meta charset='UTF-8'>" +
            "<style>" +
            "  body{margin:0;padding:0;background:#f5f6fb;font-family:Arial,sans-serif}" +
            "  .wrapper{max-width:600px;margin:30px auto;background:#fff;border-radius:16px;" +
            "           border:1px solid #e5e7eb;overflow:hidden}" +
            "  .header{background:#00338D;padding:28px 32px;text-align:center;color:#fff}" +
            "  .header h1{margin:0;font-size:20px;font-weight:900;letter-spacing:.5px}" +
            "  .header p{margin:6px 0 0;font-size:13px;color:#bfdbfe}" +
            "  .badge{display:inline-block;background:#16a34a;color:#fff;font-size:12px;" +
            "         font-weight:700;padding:6px 16px;border-radius:999px;margin-top:14px}" +
            "  .amount-box{background:#f0fdf4;border-top:3px solid #16a34a;" +
            "              text-align:center;padding:24px}" +
            "  .amount-box .label{font-size:12px;color:#6b7280;font-weight:700;" +
            "                     text-transform:uppercase;letter-spacing:.1em}" +
            "  .amount-box .amt{font-size:40px;font-weight:900;color:#15803d;margin:8px 0 0}" +
            "  .body{padding:28px 32px}" +
            "  table{width:100%;border-collapse:collapse}" +
            "  tr{border-bottom:1px solid #f1f5f9}" +
            "  td{padding:12px 0;font-size:14px}" +
            "  td:first-child{color:#6b7280;font-weight:700;width:45%}" +
            "  td:last-child{color:#111827;font-weight:900;text-align:right}" +
            "  .footer{background:#f9fafb;border-top:1px solid #e5e7eb;" +
            "          padding:20px 32px;text-align:center}" +
            "  .footer p{font-size:12px;color:#9ca3af;margin:4px 0}" +
            "  .footer .warning{font-size:11px;color:#f59e0b;margin-top:8px}" +
            "  .amount-box-pending{background:#fffbeb;border-top:3px solid #d97706}" +
            "  .amount-box-pending .amt{color:#b45309}" +
            "</style></head><body>" +

            "<div class='wrapper'>" +

            // Header
            "  <div class='header'>" +
            "    <h1>🎓 Universiti Malaysia Terengganu</h1>" +
            "    <p>Bahagian Keselamatan — Smart Campus Disciplinary System</p>" +
            "    <span class='badge'>" + ("OFFICE".equals(paymentMethod) ? "⏳ Pending Office Verification" : "✓ Payment Confirmed") + "</span>" +
            "  </div>" +

            // Amount
            "  <div class='amount-box" + ("OFFICE".equals(paymentMethod) ? " amount-box-pending" : "") + "'>" +
            "    <div class='label'>Amount Paid</div>" +
            "    <div class='amt'>" + amountFormatted + "</div>" +
            "  </div>" +

            // Details table
            "  <div class='body'>" +
            "    <p style='font-size:14px;color:#374151;font-weight:700;margin:0 0 16px'>" +
            "      Dear " + studentName + ", your payment has been successfully recorded." +
            "    </p>" +
            "    <table>" +
            "      <tr><td>Payment ID</td><td>" + paymentId + "</td></tr>" +
            "      <tr><td>Summons ID</td><td>" + summonsId + "</td></tr>" +
            "      <tr><td>Student Name</td><td>" + studentName + "</td></tr>" +
            "      <tr><td>Matric No.</td><td>" + matricNo + "</td></tr>" +
            "      <tr><td>Offense</td><td>" + offenseName + "</td></tr>" +
            "      <tr><td>Type</td><td>" + summonsType + "</td></tr>" +
            "      <tr><td>Location</td><td>" + (location != null ? location : "—") + "</td></tr>" +
            "      <tr><td>Payment Method</td><td>" + methodLabel + "</td></tr>" +
            "      <tr><td>Payment Date</td><td>" + paymentDate + "</td></tr>" +
            "      <tr><td>Status</td><td style='color:" + ("OFFICE".equals(paymentMethod) ? "#d97706'>⏳ PENDING OFFICE VERIFICATION" : "#16a34a'>✓ PAID") + "</td></tr>" +
            "    </table>" +
            "    <div style='margin-top:20px;background:#eff6ff;border-radius:12px;" +
            "                padding:14px 18px;font-size:13px;color:#1d4ed8;font-weight:700'>" +
            "      📄 You can view and print your official receipt by logging into the " +
            "      Smart Campus portal → My Summons → My Receipts." +
            "    </div>" +
            "  </div>" +

            // Footer
            "  <div class='footer'>" +
            "    <p><b>Bahagian Keselamatan, Universiti Malaysia Terengganu</b></p>" +
            "    <p>21030 Kuala Nerus, Terengganu, Malaysia</p>" +
            "    <p>Tel: 09-668 3000 | keselamatan@umt.edu.my</p>" +
            "    <p class='warning'>⚠️ This is a system-generated email. Please do not reply.</p>" +
            "  </div>" +

            "</div></body></html>";

        msg.setContent(html, "text/html; charset=UTF-8");
        Transport.send(msg);
    }
}