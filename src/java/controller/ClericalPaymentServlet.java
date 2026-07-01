/*
 * ClericalPaymentServlet.java
 * Handles clerical staff: monitor office payments & verify/reject them.
 */
package controller;

import dao.PaymentDAO;
import model.ClericalStaff;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import util.EmailUtil;
import dao.StudentDAO;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/clerical/payments/*")
public class ClericalPaymentServlet extends HttpServlet {

    private final PaymentDAO paymentDAO = new PaymentDAO();

    // ── Session key matches dashboard.jsp: "clerical" ──
    private ClericalStaff getClerk(HttpServletRequest req) {
        return (ClericalStaff) req.getSession().getAttribute("clerical");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (getClerk(req) == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getPathInfo(); // /monitor or /review

        if (path == null || path.equals("/") || path.equals("/monitor")) {
            handleMonitor(req, resp);
        } else if (path.equals("/review")) {
            handleReviewGet(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/clerical/payments/monitor");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (getClerk(req) == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getPathInfo();

        if ("/review".equals(path)) {
            try {
                handleReviewPost(req, resp);
            } catch (ClassNotFoundException ex) {
                Logger.getLogger(ClericalPaymentServlet.class.getName())
                      .log(Level.SEVERE, null, ex);
                req.getSession().setAttribute("errorMsg", "Action failed. Please try again.");
                resp.sendRedirect(req.getContextPath() + "/clerical/payments/monitor");
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/clerical/payments/monitor");
        }
    }

    // ── GET /clerical/payments/monitor ──
    // Lists all office payments with summary stats
    private void handleMonitor(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<Map<String, String>> payments = paymentDAO.getAllOfficePayments();

            // Summary counts for stat cards
            long pending  = payments.stream()
                .filter(p -> "PENDING_OFFICE".equals(p.get("payStatus"))).count();
            long verified = payments.stream()
                .filter(p -> "PAID".equals(p.get("payStatus"))).count();
            double total  = payments.stream()
                .filter(p -> "PAID".equals(p.get("payStatus")))
                .mapToDouble(p -> Double.parseDouble(p.get("paymentAmount")))
                .sum();

            req.setAttribute("payments",       payments);
            req.setAttribute("countPending",   pending);
            req.setAttribute("countVerified",  verified);
            req.setAttribute("totalCollected", String.format("%.2f", total));

            req.getRequestDispatcher("/clerical/monitorPayment.jsp").forward(req, resp);

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "Failed to load payments.");
            resp.sendRedirect(req.getContextPath() + "/clerical/dashboard");
        }
    }

    // ── GET /clerical/payments/review?id=PAY001 ──
    // Shows full detail of one office payment
    private void handleReviewGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String paymentId = req.getParameter("id");

        if (paymentId == null || paymentId.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/clerical/payments/monitor");
            return;
        }

        try {
            Map<String, String> detail = paymentDAO.getOfficePaymentDetail(paymentId);

            if (detail == null) {
                req.getSession().setAttribute("errorMsg", "Payment record not found.");
                resp.sendRedirect(req.getContextPath() + "/clerical/payments/monitor");
                return;
            }

            req.setAttribute("payment", detail);
            req.getRequestDispatcher("/clerical/reviewPayment.jsp").forward(req, resp);

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/clerical/payments/monitor");
        }
    }

    // ── POST /clerical/payments/review ──
    // action=VERIFY → marks paid | action=REJECT → resets to unpaid
//    private void handleReviewPost(HttpServletRequest req, HttpServletResponse resp)
//            throws IOException, ClassNotFoundException {
//
//        String paymentId = req.getParameter("paymentId");
//        String summonsId = req.getParameter("summonsId");
//        String action    = req.getParameter("action"); // VERIFY or REJECT
//
//        if (paymentId == null || summonsId == null || action == null ||
//            paymentId.isBlank() || summonsId.isBlank() || action.isBlank()) {
//            req.getSession().setAttribute("errorMsg", "Invalid request.");
//            resp.sendRedirect(req.getContextPath() + "/clerical/payments/monitor");
//            return;
//        }
//
//        boolean success;
//
//        if ("VERIFY".equals(action)) {
//            success = paymentDAO.verifyOfficePayment(paymentId, summonsId);
//            req.getSession().setAttribute(
//                success ? "successMsg" : "errorMsg",
//                success
//                    ? "Payment " + paymentId + " verified. Summons " + summonsId + " is now PAID."
//                    : "Failed to verify " + paymentId + ". Please try again."
//            );
//
//        } else if ("REJECT".equals(action)) {
//            success = paymentDAO.rejectOfficePayment(paymentId, summonsId);
//            req.getSession().setAttribute(
//                success ? "successMsg" : "errorMsg",
//                success
//                    ? "Payment " + paymentId + " rejected. Summons " + summonsId + " reset to UNPAID."
//                    : "Failed to reject " + paymentId + ". Please try again."
//            );
//
//        } else {
//            req.getSession().setAttribute("errorMsg", "Unknown action.");
//        }
//
//        resp.sendRedirect(req.getContextPath() + "/clerical/payments/monitor");
//    }
    
    private void handleReviewPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ClassNotFoundException {
 
        String paymentId = req.getParameter("paymentId");
        String summonsId = req.getParameter("summonsId");
        String action    = req.getParameter("action"); // VERIFY or REJECT
 
        if (paymentId == null || summonsId == null || action == null ||
            paymentId.isBlank() || summonsId.isBlank() || action.isBlank()) {
            req.getSession().setAttribute("errorMsg", "Invalid request.");
            resp.sendRedirect(req.getContextPath() + "/clerical/payments/monitor");
            return;
        }
 
        boolean success;
 
        if ("VERIFY".equals(action)) {
            success = paymentDAO.verifyOfficePayment(paymentId, summonsId);
 
            if (success) {
                req.getSession().setAttribute("successMsg",
                    "Payment " + paymentId + " verified. Summons " + summonsId + " is now PAID.");
 
                // ── Send email receipt to student after office payment verified ──
                try {
                    // Fetch the full receipt detail to get student email & offense info
                    java.util.Map<String, String> detail = paymentDAO.getOfficePaymentDetail(paymentId);
                    if (detail != null) {
 
                        // Fetch student email from student table using matricNo
                        dao.StudentDAO studentDAO = new dao.StudentDAO();
                        model.Student stu = studentDAO.getStudentByMatricNo(detail.get("matricNo"));
 
                        if (stu != null && stu.getEmail() != null) {
                            util.EmailUtil.sendPaymentReceipt(
                                stu.getEmail(),
                                detail.get("studentName"),
                                detail.get("matricNo"),
                                paymentId,
                                summonsId,
                                detail.get("offenseName"),
                                detail.get("summonsType"),
                                detail.get("location"),
                                Double.parseDouble(detail.get("paymentAmount")),
                                detail.get("paymentDate"),
                                "OFFICE",
                                req.getContextPath()
                            );
                        }
                    }
                } catch (Exception e) {
                    // Email failure must NOT affect the verification result
                    System.out.println("=== CLERICAL EMAIL SEND FAILED (non-critical) ===");
                    System.out.println("PaymentId: " + paymentId);
                    System.out.println("Error: " + e.getMessage());
                    System.out.println("=================================================");
                }
 
            } else {
                req.getSession().setAttribute("errorMsg",
                    "Failed to verify " + paymentId + ". Please try again.");
            }
 
        } else if ("REJECT".equals(action)) {
            success = paymentDAO.rejectOfficePayment(paymentId, summonsId);
            req.getSession().setAttribute(
                success ? "successMsg" : "errorMsg",
                success
                    ? "Payment " + paymentId + " rejected. Summons " + summonsId + " reset to UNPAID."
                    : "Failed to reject " + paymentId + ". Please try again."
            );
 
        } else {
            req.getSession().setAttribute("errorMsg", "Unknown action.");
        }
 
        resp.sendRedirect(req.getContextPath() + "/clerical/payments/monitor");
    }
    
}