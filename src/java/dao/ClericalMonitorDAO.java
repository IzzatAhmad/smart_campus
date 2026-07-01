/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;
 
import util.DBConnection;
 
import java.sql.*;
import java.util.*;
 
public class ClericalMonitorDAO {
 
    // ══════════════════════════════════════════
    // ── STUDENT MONITORING ──
    // ══════════════════════════════════════════
 
    // ── Get all students with their summons stats ──
    public List<Map<String, Object>> getAllStudentsWithStats()
            throws ClassNotFoundException {
 
        List<Map<String, Object>> list = new ArrayList<>();
 
        String query =
            "SELECT " +
            "  s.student_id, s.student_name, s.matric_no, s.email, " +
            "  s.phone_number, s.faculty, " +
            "  COUNT(sm.summons_id)                              AS total_summons, " +
            "  SUM(CASE WHEN sm.status = 'UNPAID'   THEN 1 ELSE 0 END) AS unpaid, " +
            "  SUM(CASE WHEN sm.status = 'PAID'     THEN 1 ELSE 0 END) AS paid, " +
            "  SUM(CASE WHEN sm.status = 'APPEALED' THEN 1 ELSE 0 END) AS appealed, " +
            "  COALESCE(SUM(CASE WHEN sm.status = 'UNPAID' THEN sm.amount ELSE 0 END), 0) " +
            "                                                    AS outstanding, " +
            "  (SELECT COUNT(*) FROM vehicle v WHERE v.student_id = s.student_id) " +
            "                                                    AS vehicle_count " +
            "FROM student s " +
            "LEFT JOIN summons sm " +
            "  ON sm.matric_no = s.matric_no " +
            "  OR sm.plate_number IN ( " +
            "    SELECT plate_number FROM vehicle WHERE student_id = s.student_id " +
            "  ) " +
            "GROUP BY s.student_id " +
            "ORDER BY total_summons DESC, s.student_name ASC";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
 
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("studentId",    rs.getString("student_id"));
                row.put("studentName",  rs.getString("student_name"));
                row.put("matricNo",     rs.getString("matric_no"));
                row.put("email",        rs.getString("email"));
                row.put("phoneNumber",  rs.getString("phone_number"));
                row.put("faculty",      rs.getString("faculty"));
                row.put("totalSummons", rs.getInt("total_summons"));
                row.put("unpaid",       rs.getInt("unpaid"));
                row.put("paid",         rs.getInt("paid"));
                row.put("appealed",     rs.getInt("appealed"));
                row.put("outstanding",  rs.getDouble("outstanding"));
                row.put("vehicleCount", rs.getInt("vehicle_count"));
                list.add(row);
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
 
    // ── Get single student info ──
    public Map<String, Object> getStudentInfo(String studentId)
            throws ClassNotFoundException {
 
        Map<String, Object> info = new LinkedHashMap<>();
        String query =
            "SELECT " +
            "  s.*, " +
            "  COUNT(sm.summons_id) AS total_summons, " +
            "  SUM(CASE WHEN sm.status='UNPAID'   THEN 1 ELSE 0 END) AS unpaid, " +
            "  SUM(CASE WHEN sm.status='PAID'     THEN 1 ELSE 0 END) AS paid, " +
            "  SUM(CASE WHEN sm.status='APPEALED' THEN 1 ELSE 0 END) AS appealed, " +
            "  COALESCE(SUM(CASE WHEN sm.status='UNPAID' THEN sm.amount ELSE 0 END),0) AS outstanding " +
            "FROM student s " +
            "LEFT JOIN summons sm " +
            "  ON sm.matric_no = s.matric_no " +
            "  OR sm.plate_number IN (SELECT plate_number FROM vehicle WHERE student_id=s.student_id) " +
            "WHERE s.student_id = ? " +
            "GROUP BY s.student_id";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, studentId);
 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    info.put("studentId",    rs.getString("student_id"));
                    info.put("studentName",  rs.getString("student_name"));
                    info.put("matricNo",     rs.getString("matric_no"));
                    info.put("email",        rs.getString("email"));
                    info.put("phoneNumber",  rs.getString("phone_number"));
                    info.put("faculty",      rs.getString("faculty"));
                    info.put("totalSummons", rs.getInt("total_summons"));
                    info.put("unpaid",       rs.getInt("unpaid"));
                    info.put("paid",         rs.getInt("paid"));
                    info.put("appealed",     rs.getInt("appealed"));
                    info.put("outstanding",  rs.getDouble("outstanding"));
                }
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return info;
    }
 
    // ── Get all summons for a student ──
    public List<Map<String, Object>> getStudentSummons(String studentId)
            throws ClassNotFoundException {
 
        List<Map<String, Object>> list = new ArrayList<>();
        String query =
            "SELECT sm.*, o.offense_name, p.patrolName " +
            "FROM summons sm " +
            "JOIN student_offense_type o ON sm.offense_id = o.offense_id " +
            "JOIN patrolstaff p ON sm.patrol_staff_id = p.patrolStaffID " +
            "JOIN student s ON s.student_id = ? " +
            "WHERE sm.matric_no = s.matric_no " +
            "   OR sm.plate_number IN (SELECT plate_number FROM vehicle WHERE student_id = ?) " +
            "ORDER BY sm.created_at DESC";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, studentId);
            ps.setString(2, studentId);
 
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("summonsId",    rs.getString("summons_id"));
                    row.put("summonsDate",  rs.getString("summons_date"));
                    row.put("summonsType",  rs.getString("summons_type"));
                    row.put("offenseName",  rs.getString("offense_name"));
                    row.put("amount",       rs.getDouble("amount"));
                    row.put("status",       rs.getString("status"));
                    row.put("location",     rs.getString("location"));
                    row.put("plateNumber",  rs.getString("plate_number"));
                    row.put("matricNo",     rs.getString("matric_no"));
                    row.put("patrolName",   rs.getString("patrolName"));
                    row.put("description",  rs.getString("description"));
                    row.put("createdAt",    rs.getString("created_at"));
                    list.add(row);
                }
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
 
    // ── Get all vehicles for a student ──
    public List<Map<String, Object>> getStudentVehicles(String studentId)
            throws ClassNotFoundException {
 
        List<Map<String, Object>> list = new ArrayList<>();
        String query =
            "SELECT * FROM vehicle WHERE student_id = ? ORDER BY created_at DESC";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, studentId);
 
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("vehicleId",   rs.getString("vehicle_id"));
                    row.put("vehicleType", rs.getString("vehicle_type"));
                    row.put("plateNumber", rs.getString("plate_number"));
                    row.put("brand",       rs.getString("brand"));
                    row.put("color",       rs.getString("color"));
                    row.put("engineCc",    rs.getString("engine_cc"));
                    row.put("status",      rs.getString("status"));
                    row.put("createdAt",   rs.getString("created_at"));
                    list.add(row);
                }
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
 
    // ══════════════════════════════════════════
    // ── PATROL MONITORING ──
    // ══════════════════════════════════════════
 
    // ── Get all patrol staff with activity stats ──
    public List<Map<String, Object>> getAllPatrolWithStats()
            throws ClassNotFoundException {
 
        List<Map<String, Object>> list = new ArrayList<>();
        String query =
            "SELECT " +
            "  p.patrolStaffID, p.patrolName, p.email, p.phoneNumber, " +
            "  COUNT(s.summons_id)                               AS total_summons, " +
            "  SUM(CASE WHEN DATE(s.created_at) = CURDATE() THEN 1 ELSE 0 END) " +
            "                                                    AS today_summons, " +
            "  SUM(CASE WHEN s.summons_type='VEHICLE'    THEN 1 ELSE 0 END) AS vehicle_summons, " +
            "  SUM(CASE WHEN s.summons_type='MISCONDUCT' THEN 1 ELSE 0 END) AS misconduct_summons, " +
            "  MAX(s.created_at)                                AS last_activity " +
            "FROM patrolstaff p " +
            "LEFT JOIN summons s ON s.patrol_staff_id = p.patrolStaffID " +
            "GROUP BY p.patrolStaffID " +
            "ORDER BY total_summons DESC, p.patrolName ASC";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
 
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("patrolStaffId",      rs.getString("patrolStaffID"));
                row.put("patrolName",          rs.getString("patrolName"));
                row.put("email",               rs.getString("email"));
                row.put("phoneNumber",         rs.getString("phoneNumber"));
                row.put("totalSummons",        rs.getInt("total_summons"));
                row.put("todaySummons",        rs.getInt("today_summons"));
                row.put("vehicleSummons",      rs.getInt("vehicle_summons"));
                row.put("misconductSummons",   rs.getInt("misconduct_summons"));
                row.put("lastActivity",        rs.getString("last_activity"));
                list.add(row);
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
 
    // ── Get single patrol staff info ──
    public Map<String, Object> getPatrolInfo(String patrolId)
            throws ClassNotFoundException {
 
        Map<String, Object> info = new LinkedHashMap<>();
        String query =
            "SELECT p.*, " +
            "  COUNT(s.summons_id) AS total_summons, " +
            "  SUM(CASE WHEN DATE(s.created_at) = CURDATE() THEN 1 ELSE 0 END) AS today_summons, " +
            "  SUM(CASE WHEN s.summons_type='VEHICLE'    THEN 1 ELSE 0 END) AS vehicle_summons, " +
            "  SUM(CASE WHEN s.summons_type='MISCONDUCT' THEN 1 ELSE 0 END) AS misconduct_summons, " +
            "  MAX(s.created_at) AS last_activity " +
            "FROM patrolstaff p " +
            "LEFT JOIN summons s ON s.patrol_staff_id = p.patrolStaffID " +
            "WHERE p.patrolStaffID = ? " +
            "GROUP BY p.patrolStaffID";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, patrolId);
 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    info.put("patrolStaffId",    rs.getString("patrolStaffID"));
                    info.put("patrolName",        rs.getString("patrolName"));
                    info.put("email",             rs.getString("email"));
                    info.put("phoneNumber",       rs.getString("phoneNumber"));
                    info.put("totalSummons",      rs.getInt("total_summons"));
                    info.put("todaySummons",      rs.getInt("today_summons"));
                    info.put("vehicleSummons",    rs.getInt("vehicle_summons"));
                    info.put("misconductSummons", rs.getInt("misconduct_summons"));
                    info.put("lastActivity",      rs.getString("last_activity"));
                }
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return info;
    }
 
    // ── Get all summons issued by a patrol staff ──
    public List<Map<String, Object>> getPatrolSummons(String patrolId)
            throws ClassNotFoundException {
 
        List<Map<String, Object>> list = new ArrayList<>();
        String query =
            "SELECT " +
            "  sm.*, " +
            "  o.offense_name, " +
            "  CASE " +
            "    WHEN sm.matric_no IS NOT NULL THEN st.student_name " +
            "    ELSE CONCAT('Vehicle: ', sm.plate_number) " +
            "  END AS target_name, " +
            "  CASE " +
            "    WHEN sm.matric_no IS NOT NULL THEN sm.matric_no " +
            "    ELSE sm.plate_number " +
            "  END AS identifier " +
            "FROM summons sm " +
            "JOIN student_offense_type o ON sm.offense_id = o.offense_id " +
            "LEFT JOIN student st ON sm.matric_no = st.matric_no " +
            "WHERE sm.patrol_staff_id = ? " +
            "ORDER BY sm.created_at DESC";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, patrolId);
 
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("summonsId",   rs.getString("summons_id"));
                    row.put("summonsDate", rs.getString("summons_date"));
                    row.put("summonsType", rs.getString("summons_type"));
                    row.put("offenseName", rs.getString("offense_name"));
                    row.put("amount",      rs.getDouble("amount"));
                    row.put("status",      rs.getString("status"));
                    row.put("location",    rs.getString("location"));
                    row.put("targetName",  rs.getString("target_name"));
                    row.put("identifier",  rs.getString("identifier"));
                    row.put("createdAt",   rs.getString("created_at"));
                    list.add(row);
                }
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
 
    // ── Get overall system stats for clerical dashboard ──
    public Map<String, Object> getSystemStats() throws ClassNotFoundException {
        Map<String, Object> stats = new LinkedHashMap<>();
 
        String query =
            "SELECT " +
            "  (SELECT COUNT(*) FROM student)        AS total_students, " +
            "  (SELECT COUNT(*) FROM patrolstaff)    AS total_patrol, " +
            "  (SELECT COUNT(*) FROM summons)        AS total_summons, " +
            "  (SELECT COUNT(*) FROM summons WHERE status='UNPAID') AS unpaid_summons, " +
            "  (SELECT COUNT(*) FROM summons WHERE status='PAID')   AS paid_summons, " +
            "  (SELECT COUNT(*) FROM payment)        AS total_payments, " +
            "  (SELECT COALESCE(SUM(payment_amount),0) FROM payment WHERE status='PAID') AS total_collected, " +
            "  (SELECT COUNT(*) FROM vehicle WHERE status='PENDING') AS pending_vehicles";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
 
            if (rs.next()) {
                stats.put("totalStudents",   rs.getInt("total_students"));
                stats.put("totalPatrol",     rs.getInt("total_patrol"));
                stats.put("totalSummons",    rs.getInt("total_summons"));
                stats.put("unpaidSummons",   rs.getInt("unpaid_summons"));
                stats.put("paidSummons",     rs.getInt("paid_summons"));
                stats.put("totalPayments",   rs.getInt("total_payments"));
                stats.put("totalCollected",  rs.getDouble("total_collected"));
                stats.put("pendingVehicles", rs.getInt("pending_vehicles"));
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }
}
