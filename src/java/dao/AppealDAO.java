/*
 * Smart Campus - Appeal DAO
 */
package dao;

import model.Appeal;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AppealDAO {

    // ── Generate next appeal ID ──
    // Format: APP001, APP002...
    public String generateAppealId() throws ClassNotFoundException {
        String id = "APP001";
        String query = "SELECT appeal_id FROM appeal ORDER BY appeal_id DESC LIMIT 1";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                String lastId = rs.getString("appeal_id");
                int num = Integer.parseInt(lastId.replace("APP", ""));
                num++;
                id = String.format("APP%03d", num);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return id;
    }

    // ── Submit Appeal (Student) ──
    public boolean submitAppeal(Appeal a) throws ClassNotFoundException {
        String query = "INSERT INTO appeal " +
                       "(appeal_id, summons_id, student_id, appeal_reason, " +
                       "status, appeal_date) " +
                       "VALUES (?, ?, ?, ?, 'PENDING', ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, a.getAppealId());
            ps.setString(2, a.getSummonsId());
            ps.setString(3, a.getStudentId());
            ps.setString(4, a.getAppealReason());
            ps.setString(5, a.getAppealDate());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("=== AppealDAO submitAppeal ERROR ===");
            System.out.println("appeal_id  : " + a.getAppealId());
            System.out.println("summons_id : " + a.getSummonsId());
            System.out.println("student_id : " + a.getStudentId());
            System.out.println("SQL Error  : " + e.getMessage());
            System.out.println("====================================");
            e.printStackTrace();
            return false;
        }
    }

    // ── Update summons status to APPEALED ──
    public boolean updateSummonsToAppealed(String summonsId) throws ClassNotFoundException {
        String query = "UPDATE summons SET status = 'APPEALED' WHERE summons_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, summonsId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── Check if summons already has appeal ──
    public boolean hasAppeal(String summonsId) throws ClassNotFoundException {
        String query = "SELECT COUNT(*) FROM appeal WHERE summons_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, summonsId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── Get Appeal by Summons ID ──
    public Appeal getAppealBySummonsId(String summonsId) throws ClassNotFoundException {
        String query =
            "SELECT a.*, sm.offense_id, o.offense_name, sm.summons_type, sm.amount, " +
            "       st.student_name, st.matric_no, " +
            "       c.clerical_name AS reviewed_by_name " +
            "FROM appeal a " +
            "JOIN summons sm ON a.summons_id = sm.summons_id " +
            "JOIN student_offense_type o ON sm.offense_id = o.offense_id " +
            "JOIN student st ON a.student_id = st.student_id " +
            "LEFT JOIN clerical_staff c ON a.reviewed_by = c.clerical_staff_id " +
            "WHERE a.summons_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, summonsId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapResultSet(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ── Get All Appeals for Student ──
    public List<Appeal> getAppealsByStudent(String studentId) throws ClassNotFoundException {
        List<Appeal> list = new ArrayList<>();
        String query =
            "SELECT a.*, o.offense_name, sm.summons_type, sm.amount, " +
            "       st.student_name, st.matric_no, " +
            "       c.clerical_name AS reviewed_by_name " +
            "FROM appeal a " +
            "JOIN summons sm ON a.summons_id = sm.summons_id " +
            "JOIN student_offense_type o ON sm.offense_id = o.offense_id " +
            "JOIN student st ON a.student_id = st.student_id " +
            "LEFT JOIN clerical_staff c ON a.reviewed_by = c.clerical_staff_id " +
            "WHERE a.student_id = ? " +
            "ORDER BY a.created_at DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapResultSet(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ── Get All Appeals (for Clerical) ──
    public List<Appeal> getAllAppeals() throws ClassNotFoundException {
        List<Appeal> list = new ArrayList<>();
        String query =
            "SELECT a.*, o.offense_name, sm.summons_type, sm.amount, " +
            "       st.student_name, st.matric_no, " +
            "       c.clerical_name AS reviewed_by_name " +
            "FROM appeal a " +
            "JOIN summons sm ON a.summons_id = sm.summons_id " +
            "JOIN student_offense_type o ON sm.offense_id = o.offense_id " +
            "JOIN student st ON a.student_id = st.student_id " +
            "LEFT JOIN clerical_staff c ON a.reviewed_by = c.clerical_staff_id " +
            "ORDER BY " +
            "  CASE a.status WHEN 'PENDING' THEN 0 ELSE 1 END, " +
            "  a.created_at DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) list.add(mapResultSet(rs));

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ── Get Pending Appeals count ──
    public int countPendingAppeals() throws ClassNotFoundException {
        String query = "SELECT COUNT(*) FROM appeal WHERE status = 'PENDING'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) return rs.getInt(1);

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ── Review Appeal (Clerical) ──
    public boolean reviewAppeal(String appealId, String status,
                                String clericalComment, String reviewedBy,
                                String reviewedDate) throws ClassNotFoundException {

        String query = "UPDATE appeal SET status = ?, clerical_comment = ?, " +
                       "reviewed_by = ?, reviewed_date = ? " +
                       "WHERE appeal_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, status);
            ps.setString(2, clericalComment);
            ps.setString(3, reviewedBy);
            ps.setString(4, reviewedDate);
            ps.setString(5, appealId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── Update summons after review ──
    // REASONABLE → summons waived (delete or mark WAIVED)
    // MODERATELY_REASONABLE → summons amount reduced
    // UNREASONABLE → summons back to UNPAID
    public boolean updateSummonsAfterReview(String summonsId, String appealStatus,
                                            double reducedAmount)
            throws ClassNotFoundException {

        String newSummonsStatus;
        String query;

        if ("REASONABLE".equals(appealStatus)) {
            // Fully waived → mark as PAID (waived)
            newSummonsStatus = "WAIVED";
            query = "UPDATE summons SET status = ? WHERE summons_id = ?";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(query)) {
                ps.setString(1, newSummonsStatus);
                ps.setString(2, summonsId);
                return ps.executeUpdate() > 0;
            } catch (SQLException e) {
                e.printStackTrace();
                return false;
            }

        } else if ("MODERATELY_REASONABLE".equals(appealStatus)) {
            // Reduce amount → back to UNPAID with new amount
            query = "UPDATE summons SET status = 'UNPAID', amount = ? WHERE summons_id = ?";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(query)) {
                ps.setDouble(1, reducedAmount);
                ps.setString(2, summonsId);
                return ps.executeUpdate() > 0;
            } catch (SQLException e) {
                e.printStackTrace();
                return false;
            }

        } else {
            // UNREASONABLE → back to UNPAID, original amount kept
            query = "UPDATE summons SET status = 'UNPAID' WHERE summons_id = ?";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(query)) {
                ps.setString(1, summonsId);
                return ps.executeUpdate() > 0;
            } catch (SQLException e) {
                e.printStackTrace();
                return false;
            }
        }
    }

    // ── Private helper: map ResultSet to Appeal ──
    private Appeal mapResultSet(ResultSet rs) throws SQLException {
        Appeal a = new Appeal();
        a.setAppealId(rs.getString("appeal_id"));
        a.setSummonsId(rs.getString("summons_id"));
        a.setStudentId(rs.getString("student_id"));
        a.setAppealReason(rs.getString("appeal_reason"));
        a.setStatus(rs.getString("status"));
        a.setClericalComment(rs.getString("clerical_comment"));
        a.setReviewedBy(rs.getString("reviewed_by"));
        a.setAppealDate(rs.getString("appeal_date"));
        a.setReviewedDate(rs.getString("reviewed_date"));
        a.setCreatedAt(rs.getString("created_at"));

        // Display fields
        try { a.setOffenseName(rs.getString("offense_name")); }   catch (SQLException ignored) {}
        try { a.setSummonsType(rs.getString("summons_type")); }   catch (SQLException ignored) {}
        try { a.setAmount(rs.getDouble("amount")); }               catch (SQLException ignored) {}
        try { a.setStudentName(rs.getString("student_name")); }   catch (SQLException ignored) {}
        try { a.setMatricNo(rs.getString("matric_no")); }         catch (SQLException ignored) {}
        try { a.setReviewedByName(rs.getString("reviewed_by_name")); } catch (SQLException ignored) {}

        return a;
    }
}
