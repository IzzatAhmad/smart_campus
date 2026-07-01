/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

/*
 * StudentPaymentServlet.java  — FULL REPLACEMENT
 * Adds: /receipts (list), /receipt-view (single), and email on payment success.
 */
package controller;

import dao.PaymentDAO;
import dao.SummonsDAO;
import model.Payment;
import model.Student;
import model.Summons;
import util.EmailUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/student/payment/*")
public class StudentPaymentServlet extends HttpServlet {

    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final SummonsDAO summonsDAO = new SummonsDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Student s = (Student) req.getSession().getAttribute("student");
        if (s == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String path = req.getPathInfo();
        if (path == null) { resp.sendRedirect(req.getContextPath() + "/student/summons"); return; }

        switch (path) {
            case "/pay":          handlePayGet(req, resp, s);      break;
            case "/receipt":      handleReceiptGet(req, resp);     break;
            case "/receipts":     handleReceiptsList(req, resp, s); break;  // ← NEW: list all
            case "/receipt-view": handleReceiptView(req, resp, s); break;   // ← NEW: single official receipt
            default:              resp.sendRedirect(req.getContextPath() + "/student/summons");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Student s = (Student) req.getSession().getAttribute("student");
        if (s == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String path = req.getPathInfo();
        if ("/pay".equals(path)) {
            try {
                handlePayPost(req, resp, s);
            } catch (ClassNotFoundException ex) {
                Logger.getLogger(StudentPaymentServlet.class.getName()).log(Level.SEVERE, null, ex);
                req.getSession().setAttribute("errorMsg", "Payment failed. Please try again.");
                resp.sendRedirect(req.getContextPath() + "/student/summons");
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/student/summons");
        }
    }

    // ── GET /student/payment/pay?id=SUM001 ──
    private void handlePayGet(HttpServletRequest req, HttpServletResponse resp, Student s)
            throws ServletException, IOException {
        String summonsId = req.getParameter("id");
        if (summonsId == null || summonsId.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/student/summons"); return;
        }
        try {
            if (paymentDAO.isSummonsPaid(summonsId)) {
                req.getSession().setAttribute("errorMsg", "Summons " + summonsId + " has already been paid.");
                resp.sendRedirect(req.getContextPath() + "/student/summons"); return;
            }
            Summons summons = summonsDAO.getSummonsById(summonsId);
            if (summons == null) {
                req.getSession().setAttribute("errorMsg", "Summons not found.");
                resp.sendRedirect(req.getContextPath() + "/student/summons"); return;
            }
            req.setAttribute("summons", summons);
            req.getRequestDispatcher("/student/payment.jsp").forward(req, resp);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/student/summons");
        }
    }

    // ── GET /student/payment/receipt?id=PAY001 ── (post-payment confirmation page)
    private void handleReceiptGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String paymentId = req.getParameter("id");
        if (paymentId == null || paymentId.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/student/summons"); return;
        }
        Payment payment = (Payment)  req.getSession().getAttribute("lastPayment");
        Summons summons = (Summons)  req.getSession().getAttribute("lastSummons");
        if (payment == null || summons == null) {
            resp.sendRedirect(req.getContextPath() + "/student/summons"); return;
        }
        req.setAttribute("payment", payment);
        req.setAttribute("summons", summons);
        req.getRequestDispatcher("/student/payment_receipt.jsp").forward(req, resp);
    }

    // ── GET /student/payment/receipts ── NEW: list all paid receipts
    private void handleReceiptsList(HttpServletRequest req, HttpServletResponse resp, Student s)
            throws ServletException, IOException {
        try {
            List<Map<String, String>> receipts = paymentDAO.getPaidReceiptsByMatricNo(
                s.getMatricNo(), s.getStudentId()   // ← pass both
            );
            req.setAttribute("receipts", receipts);
            req.getRequestDispatcher("/student/myReceipts.jsp").forward(req, resp);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "Failed to load receipts.");
            resp.sendRedirect(req.getContextPath() + "/student/summons");
        }
    }

    // ── GET /student/payment/receipt-view?id=PAY001 ── NEW: official UMT receipt
    private void handleReceiptView(HttpServletRequest req, HttpServletResponse resp, Student s)
            throws ServletException, IOException {
        String paymentId = req.getParameter("id");
        if (paymentId == null || paymentId.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/student/payment/receipts"); return;
        }
        try {
            Map<String, String> receipt = paymentDAO.getReceiptDetail(
                paymentId, s.getMatricNo(), s.getStudentId()  // ← add studentId
            );
            if (receipt == null) {
                req.getSession().setAttribute("errorMsg", "Receipt not found.");
                resp.sendRedirect(req.getContextPath() + "/student/payment/receipts"); return;
            }
            req.setAttribute("receipt", receipt);
            req.getRequestDispatcher("/student/receiptView.jsp").forward(req, resp);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/student/payment/receipts");
        }
    }

    // ── POST /student/payment/pay ── process payment + send email
    private void handlePayPost(HttpServletRequest req, HttpServletResponse resp, Student s)
            throws IOException, ClassNotFoundException, ServletException {

        String summonsId     = req.getParameter("summonsId");
        String paymentMethod = req.getParameter("paymentMethod");
        String amountStr     = req.getParameter("amount");

        if (summonsId == null || paymentMethod == null || amountStr == null ||
            summonsId.isBlank() || paymentMethod.isBlank() || amountStr.isBlank()) {
            req.getSession().setAttribute("errorMsg", "Invalid payment request.");
            resp.sendRedirect(req.getContextPath() + "/student/summons"); return;
        }

        if (paymentDAO.isSummonsPaid(summonsId)) {
            req.getSession().setAttribute("errorMsg", "Summons " + summonsId + " has already been paid.");
            resp.sendRedirect(req.getContextPath() + "/student/summons"); return;
        }

        double amount;
        try {
            amount = Double.parseDouble(amountStr);
            if (amount <= 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("errorMsg", "Invalid amount.");
            resp.sendRedirect(req.getContextPath() + "/student/payment/pay?id=" + summonsId); return;
        }

        Summons summons = summonsDAO.getSummonsById(summonsId);
        if (summons == null) {
            req.getSession().setAttribute("errorMsg", "Summons not found.");
            resp.sendRedirect(req.getContextPath() + "/student/summons"); return;
        }

        Payment payment = new Payment();
        payment.setPaymentId(paymentDAO.generatePaymentId());
        payment.setSummonsId(summonsId);
        payment.setPaymentMethod(paymentMethod);
        payment.setPaymentAmount(amount);
        payment.setPaymentDate(LocalDate.now().toString());

        if ("ONLINE".equals(paymentMethod)) {
            String cardNo = req.getParameter("cardNumber");
            String expiry = req.getParameter("cardExpiry");
            String cvv    = req.getParameter("cvv");

            if (cardNo == null || expiry == null || cvv == null ||
                cardNo.isBlank() || expiry.isBlank() || cvv.isBlank()) {
                req.getSession().setAttribute("errorMsg", "Please fill in all card details.");
                resp.sendRedirect(req.getContextPath() + "/student/payment/pay?id=" + summonsId); return;
            }
            String cleanCardNo = cardNo.replaceAll("\\s+", "");
            if (!cleanCardNo.matches("\\d{16}")) {
                req.getSession().setAttribute("errorMsg", "Card number must be exactly 16 digits.");
                resp.sendRedirect(req.getContextPath() + "/student/payment/pay?id=" + summonsId); return;
            }
            if (!expiry.matches("(0[1-9]|1[0-2])/\\d{2}")) {
                req.getSession().setAttribute("errorMsg", "Card expiry must be in MM/YY format.");
                resp.sendRedirect(req.getContextPath() + "/student/payment/pay?id=" + summonsId); return;
            }
            try {
                String[] parts = expiry.split("/");
                int expMonth = Integer.parseInt(parts[0]);
                int expYear  = Integer.parseInt("20" + parts[1]);
                if (expYear < LocalDate.now().getYear() ||
                   (expYear == LocalDate.now().getYear() && expMonth < LocalDate.now().getMonthValue())) {
                    req.getSession().setAttribute("errorMsg", "Your card has expired.");
                    resp.sendRedirect(req.getContextPath() + "/student/payment/pay?id=" + summonsId); return;
                }
            } catch (Exception e) {
                req.getSession().setAttribute("errorMsg", "Invalid card expiry date.");
                resp.sendRedirect(req.getContextPath() + "/student/payment/pay?id=" + summonsId); return;
            }
            if (!cvv.matches("\\d{3}")) {
                req.getSession().setAttribute("errorMsg", "CVV must be exactly 3 digits.");
                resp.sendRedirect(req.getContextPath() + "/student/payment/pay?id=" + summonsId); return;
            }
            payment.setBankCardNo(cleanCardNo);
            payment.setCardExpiry(expiry);
            payment.setStatus("PAID");
        } else {
            payment.setStatus("PENDING_OFFICE");
        }

        boolean saved = paymentDAO.createPayment(payment);
        if (!saved) {
            req.getSession().setAttribute("errorMsg", "Payment processing failed. Please try again.");
            resp.sendRedirect(req.getContextPath() + "/student/payment/pay?id=" + summonsId); return;
        }

        String newSummonsStatus = "ONLINE".equals(paymentMethod) ? "PAID" : "PENDING_OFFICE";
        paymentDAO.updateSummonsStatus(summonsId, newSummonsStatus);

        // ── Send email receipt for both ONLINE and OFFICE payments ──
        // For ONLINE: immediately confirmed (PAID)
        // For OFFICE: pending verification, but student still gets a confirmation email
        try {
            EmailUtil.sendPaymentReceipt(
                s.getEmail(),
                s.getStudentName(),
                s.getMatricNo(),
                payment.getPaymentId(),
                summonsId,
                summons.getOffenseName() != null ? summons.getOffenseName() : summons.getSummonsType(),
                summons.getSummonsType(),
                summons.getLocation(),
                amount,
                payment.getPaymentDate(),
                paymentMethod,
                req.getContextPath()
            );
        } catch (Exception e) {
            // Email failure should NOT block the payment success flow
            System.out.println("=== EMAIL SEND FAILED (non-critical) ===");
            System.out.println("To: " + s.getEmail());
            System.out.println("Error: " + e.getMessage());
            System.out.println("========================================");
        }

        req.getSession().setAttribute("lastPayment", payment);
        req.getSession().setAttribute("lastSummons", summons);
        resp.sendRedirect(req.getContextPath() + "/student/payment/receipt?id=" + payment.getPaymentId());
    }
}