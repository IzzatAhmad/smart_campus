/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;
 
import model.Payment;
import util.DBConnection;
import java.util.Map;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
 
public class PaymentDAO {
 
    // ── Generate next payment ID ──
    // Format: PAY001, PAY002...
    public String generatePaymentId() throws ClassNotFoundException {
        String id = "PAY001";
        String query = "SELECT payment_id FROM payment ORDER BY payment_id DESC LIMIT 1";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
 
            if (rs.next()) {
                String lastId = rs.getString("payment_id");
                int num = Integer.parseInt(lastId.replace("PAY", ""));
                num++;
                id = String.format("PAY%03d", num);
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return id;
    }
 
    // ── Create Payment Record ──
    public boolean createPayment(Payment p) throws ClassNotFoundException {
        String query = "INSERT INTO payment " +
                       "(payment_id, summons_id, payment_method, payment_amount, " +
                       "bank_card_no, card_expiry, status, payment_date) " +
                       "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, p.getPaymentId());
            ps.setString(2, p.getSummonsId());
            ps.setString(3, p.getPaymentMethod());
            ps.setDouble(4, p.getPaymentAmount());
 
            // For OFFICE payment, card details are null
            if (p.getBankCardNo() != null && !p.getBankCardNo().isBlank()) {
                ps.setString(5, p.getBankCardNo());
                ps.setString(6, p.getCardExpiry());
            } else {
                ps.setNull(5, Types.VARCHAR);
                ps.setNull(6, Types.VARCHAR);
            }
 
            ps.setString(7, p.getStatus());
            ps.setString(8, p.getPaymentDate());
 
            return ps.executeUpdate() > 0;
 
        } catch (SQLException e) {
            System.out.println("=== PaymentDAO createPayment ERROR ===");
            System.out.println("payment_id  : " + p.getPaymentId());
            System.out.println("summons_id  : " + p.getSummonsId());
            System.out.println("method      : " + p.getPaymentMethod());
            System.out.println("SQL Error   : " + e.getMessage());
            System.out.println("======================================");
            e.printStackTrace();
            return false;
        }
    }
 
    // ── Update Summons Status after Payment ──
    public boolean updateSummonsStatus(String summonsId, String newStatus)
            throws ClassNotFoundException {
 
        String query = "UPDATE summons SET status = ? WHERE summons_id = ?";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, newStatus);
            ps.setString(2, summonsId);
 
            return ps.executeUpdate() > 0;
 
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
 
    // ── Get Payment by Summons ID ──
    public Payment getPaymentBySummonsId(String summonsId) throws ClassNotFoundException {
        String query = "SELECT * FROM payment WHERE summons_id = ? ORDER BY created_at DESC LIMIT 1";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, summonsId);
 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Payment p = new Payment();
                    p.setPaymentId(rs.getString("payment_id"));
                    p.setSummonsId(rs.getString("summons_id"));
                    p.setPaymentMethod(rs.getString("payment_method"));
                    p.setPaymentAmount(rs.getDouble("payment_amount"));
                    p.setBankCardNo(rs.getString("bank_card_no"));
                    p.setCardExpiry(rs.getString("card_expiry"));
                    p.setStatus(rs.getString("status"));
                    p.setPaymentDate(rs.getString("payment_date"));
                    p.setCreatedAt(rs.getString("created_at"));
                    return p;
                }
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
 
    // ── Check if summons already paid ──
    public boolean isSummonsPaid(String summonsId) throws ClassNotFoundException {
        String query = "SELECT status FROM summons WHERE summons_id = ?";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, summonsId);
 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String status = rs.getString("status");
                    return "PAID".equals(status) || "PENDING_OFFICE".equals(status);
                }
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
     public List<Map<String, String>> getAllOfficePayments() throws ClassNotFoundException {
        List<Map<String, String>> list = new ArrayList<>();
 
        String query =
            "SELECT p.payment_id, p.summons_id, p.payment_amount, p.payment_date, p.status AS pay_status, " +
            "       s.summons_type, s.location, " +
            "       COALESCE(st.student_name, sv.student_name, " +
            "           CASE WHEN s.matric_no IS NULL AND s.plate_number IS NULL THEN '[Deleted Student]' ELSE 'N/A' END) AS student_name, " +
            "       COALESCE(st.matric_no, sv.matric_no, " +
            "           CASE WHEN s.matric_no IS NULL AND s.plate_number IS NULL THEN '[Deleted]' ELSE 'N/A' END) AS matric_no " +
            "FROM payment p " +
            "JOIN summons s ON p.summons_id = s.summons_id " +
            "LEFT JOIN student st ON s.matric_no = st.matric_no " +
            "LEFT JOIN vehicle v ON s.plate_number = v.plate_number " +
            "LEFT JOIN student sv ON v.student_id = sv.student_id " +
            "WHERE p.payment_method = 'OFFICE' " +
            "ORDER BY p.payment_date DESC";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
 
            while (rs.next()) {
                Map<String, String> row = new java.util.LinkedHashMap<>();
                row.put("paymentId",     rs.getString("payment_id"));
                row.put("summonsId",     rs.getString("summons_id"));
                row.put("paymentAmount", String.valueOf(rs.getDouble("payment_amount")));
                row.put("paymentDate",   rs.getString("payment_date"));
                row.put("payStatus",     rs.getString("pay_status"));
                row.put("summonsType",   rs.getString("summons_type"));
                row.put("location",      rs.getString("location"));
                row.put("studentName",   rs.getString("student_name"));
                row.put("matricNo",      rs.getString("matric_no"));
                list.add(row);
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
 
    // ── Get single office payment detail (for review page) ──
    public Map<String, String> getOfficePaymentDetail(String paymentId)
            throws ClassNotFoundException {
 
        String query =
            "SELECT p.payment_id, p.summons_id, p.payment_amount, p.payment_date, p.status AS pay_status, " +
            "       s.summons_type, s.location, s.amount AS summons_amount, " +
            "       COALESCE(st.student_name, sv.student_name, " +
            "           CASE WHEN s.matric_no IS NULL AND s.plate_number IS NULL THEN '[Deleted Student]' ELSE 'N/A' END) AS student_name, " +
            "       COALESCE(st.student_id, sv.student_id, 'N/A') AS student_id, " +
            "       COALESCE(st.matric_no, sv.matric_no, " +
            "           CASE WHEN s.matric_no IS NULL AND s.plate_number IS NULL THEN '[Deleted]' ELSE 'N/A' END) AS matric_no, " +
            "       COALESCE(ot.offense_name, 'N/A') AS offense_name " +
            "FROM payment p " +
            "JOIN summons s ON p.summons_id = s.summons_id " +
            "LEFT JOIN student st ON s.matric_no = st.matric_no " +
            "LEFT JOIN vehicle v ON s.plate_number = v.plate_number " +
            "LEFT JOIN student sv ON v.student_id = sv.student_id " +
            "LEFT JOIN student_offense_type ot ON s.offense_id = ot.offense_id " +
            "WHERE p.payment_id = ? AND p.payment_method = 'OFFICE'";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, paymentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, String> row = new java.util.LinkedHashMap<>();
                    row.put("paymentId",     rs.getString("payment_id"));
                    row.put("summonsId",     rs.getString("summons_id"));
                    row.put("paymentAmount", String.valueOf(rs.getDouble("payment_amount")));
                    row.put("paymentDate",   rs.getString("payment_date"));
                    row.put("payStatus",     rs.getString("pay_status"));
                    row.put("summonsType",   rs.getString("summons_type"));
                    row.put("location",      rs.getString("location"));
                    row.put("studentName",   rs.getString("student_name"));
                    row.put("studentId",     rs.getString("student_id"));
                    row.put("matricNo",      rs.getString("matric_no"));
                    row.put("offenseName",   rs.getString("offense_name"));
                    return row;
                }
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
 
    // ── Verify Office Payment ──
    // Sets payment.status = 'PAID' and summons.status = 'PAID' in one transaction
    public boolean verifyOfficePayment(String paymentId, String summonsId)
            throws ClassNotFoundException {
 
        String updatePayment = "UPDATE payment SET status = 'PAID' WHERE payment_id = ?";
        String updateSummons = "UPDATE summons SET status = 'PAID', updated_at = NOW() WHERE summons_id = ?";
 
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement ps1 = con.prepareStatement(updatePayment);
                 PreparedStatement ps2 = con.prepareStatement(updateSummons)) {
 
                ps1.setString(1, paymentId);
                ps2.setString(1, summonsId);
 
                int r1 = ps1.executeUpdate();
                int r2 = ps2.executeUpdate();
 
                if (r1 > 0 && r2 > 0) { con.commit(); return true; }
                else                   { con.rollback(); return false; }
 
            } catch (SQLException e) {
                con.rollback();
                e.printStackTrace();
                return false;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
 
    // ── Reject Office Payment ──
    // Deletes the PENDING_OFFICE record and resets summons to 'UNPAID'
    // so the student can pay again (online or re-visit office)
    public boolean rejectOfficePayment(String paymentId, String summonsId)
            throws ClassNotFoundException {
 
        String deletePayment = "DELETE FROM payment WHERE payment_id = ?";
        String updateSummons = "UPDATE summons SET status = 'UNPAID', updated_at = NOW() WHERE summons_id = ?";
 
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement ps1 = con.prepareStatement(deletePayment);
                 PreparedStatement ps2 = con.prepareStatement(updateSummons)) {
 
                ps1.setString(1, paymentId);
                ps2.setString(1, summonsId);
 
                int r1 = ps1.executeUpdate();
                int r2 = ps2.executeUpdate();
 
                if (r1 > 0 && r2 > 0) { con.commit(); return true; }
                else                   { con.rollback(); return false; }
 
            } catch (SQLException e) {
                con.rollback();
                e.printStackTrace();
                return false;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    

    // ── Get all PAID receipts for a student (for My Receipts page) ──
    // Shows: online payments (PAID) + office payments verified by clerical (PAID)
    public List<Map<String, String>> getPaidReceiptsByMatricNo(String matricNo, String studentId)
            throws ClassNotFoundException {
        List<Map<String, String>> list = new ArrayList<>();
        String query =
            "SELECT p.payment_id, p.summons_id, p.payment_method, p.payment_amount, " +
            "       p.payment_date, p.status AS pay_status, " +
            "       s.summons_type, s.location, s.summons_date, " +
            "       COALESCE(ot.offense_name, s.summons_type) AS offense_name " +
            "FROM payment p " +
            "JOIN summons s ON p.summons_id = s.summons_id " +
            "LEFT JOIN student_offense_type ot ON s.offense_id = ot.offense_id " +
            "WHERE (s.matric_no = ? " +
            "   OR s.plate_number IN (SELECT plate_number FROM vehicle WHERE student_id = ?)) " +
            "  AND p.status = 'PAID' " +
            "ORDER BY p.payment_date DESC, p.payment_id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
            ps.setString(1, matricNo);
            ps.setString(2, studentId);   // ← second parameter
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> row = new java.util.LinkedHashMap<>();
                    row.put("paymentId",     rs.getString("payment_id"));
                    row.put("summonsId",     rs.getString("summons_id"));
                    row.put("paymentMethod", rs.getString("payment_method"));
                    row.put("paymentAmount", String.valueOf(rs.getDouble("payment_amount")));
                    row.put("paymentDate",   rs.getString("payment_date"));
                    row.put("summonsDate",   rs.getString("summons_date"));
                    row.put("summonsType",   rs.getString("summons_type"));
                    row.put("location",      rs.getString("location"));
                    row.put("offenseName",   rs.getString("offense_name"));
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ── Get a single receipt detail by paymentId (for receipt view page) ──
    public Map<String, String> getReceiptDetail(String paymentId, String matricNo, String studentId)
            throws ClassNotFoundException {

        String query =
            "SELECT p.payment_id, p.summons_id, p.payment_method, p.payment_amount, " +
            "       p.payment_date, p.bank_card_no, p.card_expiry, p.status AS pay_status, " +
            "       s.summons_type, s.location, s.summons_date, s.amount AS summons_amount, " +
            "       st.student_name, st.matric_no, st.faculty, st.email, " +
            "       COALESCE(ot.offense_name, s.summons_type) AS offense_name " +
            "FROM payment p " +
            "JOIN summons s ON p.summons_id = s.summons_id " +
            "JOIN student st ON (st.matric_no = s.matric_no " +
            "                OR  st.student_id = (SELECT student_id FROM vehicle WHERE plate_number = s.plate_number LIMIT 1)) " +
            "LEFT JOIN student_offense_type ot ON s.offense_id = ot.offense_id " +
            "WHERE p.payment_id = ? " +
            "  AND st.student_id = ? " +
            "  AND p.status = 'PAID'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, paymentId);
            ps.setString(2, studentId);   // ← use student_id instead of matric_no for the WHERE

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, String> row = new java.util.LinkedHashMap<>();
                    row.put("paymentId",     rs.getString("payment_id"));
                    row.put("summonsId",     rs.getString("summons_id"));
                    row.put("paymentMethod", rs.getString("payment_method"));
                    row.put("paymentAmount", String.valueOf(rs.getDouble("payment_amount")));
                    row.put("paymentDate",   rs.getString("payment_date"));
                    row.put("bankCardNo",    rs.getString("bank_card_no"));
                    row.put("cardExpiry",    rs.getString("card_expiry"));
                    row.put("summonsDate",   rs.getString("summons_date"));
                    row.put("summonsType",   rs.getString("summons_type"));
                    row.put("location",      rs.getString("location"));
                    row.put("offenseName",   rs.getString("offense_name"));
                    row.put("studentName",   rs.getString("student_name"));
                    row.put("matricNo",      rs.getString("matric_no"));
                    row.put("faculty",       rs.getString("faculty"));
                    row.put("email",         rs.getString("email"));
                    return row;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
}