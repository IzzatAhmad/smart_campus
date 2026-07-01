/*
 * ReportDAO.java
 * Place in: src/java/dao/ReportDAO.java
 */
package dao;

import util.DBConnection;
import java.sql.*;
import java.util.*;

public class ReportDAO {

    // ── 1. Monthly Summons Count (for bar chart + table) ──
    // Returns list of {month, year, total, vehicle, misconduct}
    public List<Map<String, String>> getMonthlySummons(int year) throws ClassNotFoundException {
        List<Map<String, String>> list = new ArrayList<>();

        String query =
            "SELECT MONTH(summons_date) AS month, " +
            "       COUNT(*) AS total, " +
            "       SUM(CASE WHEN summons_type='VEHICLE'    THEN 1 ELSE 0 END) AS vehicle, " +
            "       SUM(CASE WHEN summons_type='MISCONDUCT' THEN 1 ELSE 0 END) AS misconduct " +
            "FROM summons " +
            "WHERE YEAR(summons_date) = ? " +
            "GROUP BY MONTH(summons_date) " +
            "ORDER BY MONTH(summons_date)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {

            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> row = new LinkedHashMap<>();
                    row.put("month",      String.valueOf(rs.getInt("month")));
                    row.put("total",      String.valueOf(rs.getInt("total")));
                    row.put("vehicle",    String.valueOf(rs.getInt("vehicle")));
                    row.put("misconduct", String.valueOf(rs.getInt("misconduct")));
                    list.add(row);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── 2. Monthly Payment & Collection (for bar chart + table) ──
    // Returns list of {month, totalPayments, totalCollected}
    public List<Map<String, String>> getMonthlyPayments(int year) throws ClassNotFoundException {
        List<Map<String, String>> list = new ArrayList<>();

        String query =
            "SELECT MONTH(payment_date) AS month, " +
            "       COUNT(*) AS total_payments, " +
            "       SUM(payment_amount) AS total_collected " +
            "FROM payment " +
            "WHERE YEAR(payment_date) = ? AND status = 'PAID' " +
            "GROUP BY MONTH(payment_date) " +
            "ORDER BY MONTH(payment_date)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {

            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> row = new LinkedHashMap<>();
                    row.put("month",           String.valueOf(rs.getInt("month")));
                    row.put("totalPayments",   String.valueOf(rs.getInt("total_payments")));
                    row.put("totalCollected",  String.format("%.2f", rs.getDouble("total_collected")));
                    list.add(row);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── 3. Offense Type Breakdown (for pie chart) ──
    // Returns list of {offenseName, count}
    public List<Map<String, String>> getOffenseTypeBreakdown(int year) throws ClassNotFoundException {
        List<Map<String, String>> list = new ArrayList<>();

        String query =
            "SELECT COALESCE(ot.offense_name, s.summons_type) AS offense_name, " +
            "       COUNT(*) AS total " +
            "FROM summons s " +
            "LEFT JOIN student_offense_type ot ON s.offense_id = ot.offense_id " +
            "WHERE YEAR(s.summons_date) = ? " +
            "GROUP BY offense_name " +
            "ORDER BY total DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {

            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> row = new LinkedHashMap<>();
                    row.put("offenseName", rs.getString("offense_name"));
                    row.put("count",       String.valueOf(rs.getInt("total")));
                    list.add(row);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── 4. Top Hotspot Locations ──
    // Returns list of {location, count}
    public List<Map<String, String>> getHotspots(int year) throws ClassNotFoundException {
        List<Map<String, String>> list = new ArrayList<>();

        String query =
            "SELECT location, COUNT(*) AS total " +
            "FROM summons " +
            "WHERE YEAR(summons_date) = ? AND location IS NOT NULL AND location != '' " +
            "GROUP BY location " +
            "ORDER BY total DESC " +
            "LIMIT 10";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {

            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> row = new LinkedHashMap<>();
                    row.put("location", rs.getString("location"));
                    row.put("count",    String.valueOf(rs.getInt("total")));
                    list.add(row);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── 5. Summary Stats for selected year ──
    // Returns single map: {totalSummons, totalPaid, totalUnpaid, totalCollected, totalStudents}
    public Map<String, String> getYearSummary(int year) throws ClassNotFoundException {
        Map<String, String> summary = new LinkedHashMap<>();

        String q1 =
            "SELECT COUNT(*) AS total, " +
            "       SUM(CASE WHEN status='PAID'   THEN 1 ELSE 0 END) AS paid, " +
            "       SUM(CASE WHEN status='UNPAID' THEN 1 ELSE 0 END) AS unpaid " +
            "FROM summons WHERE YEAR(summons_date) = ?";

        String q2 =
            "SELECT COALESCE(SUM(payment_amount),0) AS collected " +
            "FROM payment WHERE YEAR(payment_date) = ? AND status='PAID'";

        String q3 =
            "SELECT COUNT(DISTINCT matric_no) AS students " +
            "FROM summons WHERE YEAR(summons_date) = ? AND matric_no IS NOT NULL";

        try (Connection con = DBConnection.getConnection()) {

            try (PreparedStatement ps = con.prepareStatement(q1)) {
                ps.setInt(1, year);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        summary.put("totalSummons", String.valueOf(rs.getInt("total")));
                        summary.put("totalPaid",    String.valueOf(rs.getInt("paid")));
                        summary.put("totalUnpaid",  String.valueOf(rs.getInt("unpaid")));
                    }
                }
            }

            try (PreparedStatement ps = con.prepareStatement(q2)) {
                ps.setInt(1, year);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next())
                        summary.put("totalCollected", String.format("%.2f", rs.getDouble("collected")));
                }
            }

            try (PreparedStatement ps = con.prepareStatement(q3)) {
                ps.setInt(1, year);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next())
                        summary.put("totalStudents", String.valueOf(rs.getInt("students")));
                }
            }

        } catch (SQLException e) { e.printStackTrace(); }
        return summary;
    }

    // ── 6. Monthly detail for a specific month (for export) ──
    // Returns each summons row for the given month/year
    public List<Map<String, String>> getMonthlyDetail(int year, int month) throws ClassNotFoundException {
        List<Map<String, String>> list = new ArrayList<>();

        String query =
            "SELECT s.summons_id, s.summons_date, s.summons_type, " +
            "       COALESCE(ot.offense_name, s.summons_type) AS offense_name, " +
            "       s.location, s.amount, s.status, " +
            "       COALESCE(st.student_name, sv.student_name, " +
            "           CASE WHEN s.matric_no IS NULL AND s.plate_number IS NULL THEN '[Deleted Student]' ELSE 'N/A' END) AS student_name, " +
            "       COALESCE(st.matric_no, sv.matric_no, " +
            "           CASE WHEN s.matric_no IS NULL AND s.plate_number IS NULL THEN '[Deleted]' ELSE 'N/A' END) AS matric_no, " +
            "       COALESCE(p.payment_amount, 0) AS payment_amount, " +
            "       COALESCE(p.payment_method, 'N/A') AS payment_method, " +
            "       COALESCE(p.payment_date,   'N/A') AS payment_date " +
            "FROM summons s " +
            "LEFT JOIN student_offense_type ot ON s.offense_id = ot.offense_id " +
            "LEFT JOIN student st ON s.matric_no = st.matric_no " +
            "LEFT JOIN vehicle v ON s.plate_number = v.plate_number " +
            "LEFT JOIN student sv ON v.student_id = sv.student_id " +
            "LEFT JOIN payment p ON s.summons_id = p.summons_id AND p.status = 'PAID' " +
            "WHERE YEAR(s.summons_date) = ? AND MONTH(s.summons_date) = ? " +
            "ORDER BY s.summons_date";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {

            ps.setInt(1, year);
            ps.setInt(2, month);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> row = new LinkedHashMap<>();
                    row.put("summonsId",     rs.getString("summons_id"));
                    row.put("summonsDate",   rs.getString("summons_date"));
                    row.put("summonsType",   rs.getString("summons_type"));
                    row.put("offenseName",   rs.getString("offense_name"));
                    row.put("location",      rs.getString("location"));
                    row.put("amount",        String.format("%.2f", rs.getDouble("amount")));
                    row.put("status",        rs.getString("status"));
                    row.put("studentName",   rs.getString("student_name"));
                    row.put("matricNo",      rs.getString("matric_no"));
                    row.put("paymentAmount", String.format("%.2f", rs.getDouble("payment_amount")));
                    row.put("paymentMethod", rs.getString("payment_method"));
                    row.put("paymentDate",   rs.getString("payment_date"));
                    list.add(row);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── 7. Get available years (for year filter dropdown) ──
    public List<Integer> getAvailableYears() throws ClassNotFoundException {
        List<Integer> years = new ArrayList<>();
        String query = "SELECT DISTINCT YEAR(summons_date) AS yr FROM summons ORDER BY yr DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) years.add(rs.getInt("yr"));

        } catch (SQLException e) { e.printStackTrace(); }

        if (years.isEmpty()) years.add(java.time.Year.now().getValue());
        return years;
    }
}