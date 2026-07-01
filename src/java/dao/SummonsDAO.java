/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;
 
import model.Summons;
import util.DBConnection;
 
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
 
public class SummonsDAO {
 
    // ── Get Student Info by Plate Number ──
    // Used by AJAX lookup in create summons form
    public java.util.Map<String, String> getStudentByPlateNumber(String plateNumber)
            throws ClassNotFoundException {
 
        java.util.Map<String, String> result = new java.util.HashMap<>();
        String query = "SELECT s.student_name, s.matric_no, s.faculty, " +
                       "v.plate_number, v.brand, v.vehicle_type, v.color " +
                       "FROM vehicle v " +
                       "JOIN student s ON v.student_id = s.student_id " +
                       "WHERE v.plate_number = ? AND v.status = 'APPROVED'";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, plateNumber.toUpperCase().trim());
 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    result.put("found",       "true");
                    result.put("studentName", rs.getString("student_name"));
                    result.put("matricNo",    rs.getString("matric_no"));
                    result.put("faculty",     rs.getString("faculty"));
                    result.put("plateNumber", rs.getString("plate_number"));
                    result.put("brand",       rs.getString("brand"));
                    result.put("vehicleType", rs.getString("vehicle_type"));
                    result.put("color",       rs.getString("color"));
                } else {
                    result.put("found", "false");
                }
            }
 
        } catch (SQLException e) {
            System.out.println("=== getStudentByPlateNumber ERROR ===");
            System.out.println("plateNumber: " + plateNumber);
            System.out.println("SQL Error  : " + e.getMessage());
            System.out.println("=====================================");
            e.printStackTrace();
            result.put("found", "false");
            result.put("error", e.getMessage());
        }
        return result;
    }
 
    // ── Generate next summons ID ──
    // Format: SUM001, SUM002...
    public String generateSummonsId() throws ClassNotFoundException {
        String id = "SUM001";
        String query = "SELECT summons_id FROM summons " +
                       "ORDER BY summons_id DESC LIMIT 1";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
 
            if (rs.next()) {
                String lastId = rs.getString("summons_id");
                int num = Integer.parseInt(lastId.replace("SUM", ""));
                num++;
                id = String.format("SUM%03d", num);
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return id;
    }
 
    // ── Create Summons ──
    public boolean createSummons(Summons s) throws ClassNotFoundException {
        String query = "INSERT INTO summons " +
                       "(summons_id, summons_date, summons_type, offense_id, " +
                       "description, amount, status, location, " +
                       "plate_number, matric_no, patrol_staff_id, evidence_path) " +
                       "VALUES (?, ?, ?, ?, ?, ?, 'UNPAID', ?, ?, ?, ?, ?)";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, s.getSummonsId());
            ps.setString(2, s.getSummonsDate());
            ps.setString(3, s.getSummonsType());
            ps.setString(4, s.getOffenseId());
            ps.setString(5, s.getDescription());
            ps.setDouble(6, s.getAmount());
            ps.setString(7, s.getLocation());
 
            // VEHICLE → set plate_number, matric_no = null
            // MISCONDUCT → set matric_no, plate_number = null
            if ("VEHICLE".equals(s.getSummonsType())) {
                ps.setString(8, s.getPlateNumber());
                ps.setNull(9, Types.VARCHAR);
            } else {
                ps.setNull(8, Types.VARCHAR);
                ps.setString(9, s.getMatricNo());
            }
 
            ps.setString(10, s.getPatrolStaffId());
            ps.setString(11, s.getEvidencePath());   // may be null if no photo was uploaded
 
            return ps.executeUpdate() > 0;
 
        } catch (SQLException e) {
            System.out.println("=== SummonsDAO createSummons ERROR ===");
            System.out.println("summons_id     : " + s.getSummonsId());
            System.out.println("summons_type   : " + s.getSummonsType());
            System.out.println("offense_id     : " + s.getOffenseId());
            System.out.println("plate_number   : " + s.getPlateNumber());
            System.out.println("matric_no      : " + s.getMatricNo());
            System.out.println("patrol_staff_id: " + s.getPatrolStaffId());
            System.out.println("evidence_path  : " + s.getEvidencePath());
            System.out.println("SQL Error      : " + e.getMessage());
            System.out.println("======================================");
            e.printStackTrace();
            return false;
        }
    }
 
    // ── Get All Summons by Patrol Staff ──
    public List<Summons> getSummonsByPatrol(String patrolStaffId) 
            throws ClassNotFoundException {
 
        List<Summons> list = new ArrayList<>();
        String query = "SELECT s.*, o.offense_name " +
                       "FROM summons s " +
                       "JOIN student_offense_type o ON s.offense_id = o.offense_id " +
                       "WHERE s.patrol_staff_id = ? " +
                       "ORDER BY s.created_at DESC";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, patrolStaffId);
 
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Summons s = mapResultSet(rs);
                    list.add(s);
                }
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
 
    // ── Get All Summons (for Clerical) ──
    public List<Summons> getAllSummons() throws ClassNotFoundException {
        List<Summons> list = new ArrayList<>();
        String query = "SELECT s.*, o.offense_name, p.patrolName " +
                       "FROM summons s " +
                       "JOIN student_offense_type o ON s.offense_id = o.offense_id " +
                       "JOIN patrolstaff p ON s.patrol_staff_id = p.patrolStaffID " +
                       "ORDER BY s.created_at DESC";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
 
            while (rs.next()) {
                Summons s = mapResultSet(rs);
                s.setPatrolStaffName(rs.getString("patrolName"));
                list.add(s);
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
 

    // ── Get All Summons filtered by year+month for Clerical (0 = all months) ──
    public List<Summons> getAllSummonsFiltered(int year, int month) throws ClassNotFoundException {
        List<Summons> list = new ArrayList<>();

        StringBuilder query = new StringBuilder(
            "SELECT s.*, " +
            "       COALESCE(o.offense_name, s.summons_type) AS offense_name, " +
            "       p.patrolName, " +
            "       COALESCE(st.student_name, sv.student_name, " +
            "           CASE WHEN s.matric_no IS NULL AND s.plate_number IS NULL THEN '[Deleted Student]' ELSE 'N/A' END) AS student_name, " +
            "       COALESCE(s.matric_no, sv.matric_no, " +
            "           CASE WHEN s.matric_no IS NULL AND s.plate_number IS NULL THEN '[Deleted]' ELSE 'N/A' END) AS identifier_matric " +
            "FROM summons s " +
            "LEFT JOIN student_offense_type o ON s.offense_id = o.offense_id " +
            "LEFT JOIN patrolstaff p ON s.patrol_staff_id = p.patrolStaffID " +
            "LEFT JOIN student st ON s.matric_no = st.matric_no " +
            "LEFT JOIN vehicle v ON s.plate_number = v.plate_number " +
            "LEFT JOIN student sv ON v.student_id = sv.student_id " +
            "WHERE 1=1 "
        );

        if (year > 0) {
            query.append("AND YEAR(s.summons_date) = ").append(year).append(" ");
        }
        if (month > 0) {
            query.append("AND MONTH(s.summons_date) = ").append(month).append(" ");
        }
        query.append("ORDER BY s.summons_date DESC, s.created_at DESC");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query.toString());
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Summons s = mapResultSet(rs);
                s.setPatrolStaffName(rs.getString("patrolName"));
                list.add(s);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ── Get Summons By ID ──
    public Summons getSummonsById(String summonsId) throws ClassNotFoundException {
        String query = "SELECT s.*, o.offense_name, p.patrolName " +
                       "FROM summons s " +
                       "JOIN student_offense_type o ON s.offense_id = o.offense_id " +
                       "JOIN patrolstaff p ON s.patrol_staff_id = p.patrolStaffID " +
                       "WHERE s.summons_id = ?";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, summonsId);
 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Summons s = mapResultSet(rs);
                    s.setPatrolStaffName(rs.getString("patrolName"));
                    return s;
                }
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
 
    // ── Check if plate number exists in vehicle table ──
    public boolean isPlateNumberExists(String plateNumber) throws ClassNotFoundException {
        String query = "SELECT COUNT(*) FROM vehicle " +
                       "WHERE plate_number = ? AND status = 'APPROVED'";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, plateNumber);
 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
 
    // ── Check if matric number exists in student table ──
    public boolean isMatricNoExists(String matricNo) throws ClassNotFoundException {
        String query = "SELECT COUNT(*) FROM student WHERE matric_no = ?";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, matricNo);
 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
 
    // ── Count summons by patrol staff today ──
    public int countTodayByPatrol(String patrolStaffId) throws ClassNotFoundException {
        String query = "SELECT COUNT(*) FROM summons " +
                       "WHERE patrol_staff_id = ? AND DATE(created_at) = CURDATE()";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, patrolStaffId);
 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
 
    // ── Count total summons by patrol staff ──
    public int countTotalByPatrol(String patrolStaffId) throws ClassNotFoundException {
        String query = "SELECT COUNT(*) FROM summons WHERE patrol_staff_id = ?";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, patrolStaffId);
 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
 
    // ── Count pending summons by patrol staff ──
    public int countPendingByPatrol(String patrolStaffId) throws ClassNotFoundException {
        String query = "SELECT COUNT(*) FROM summons " +
                       "WHERE patrol_staff_id = ? AND status = 'UNPAID'";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, patrolStaffId);
 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
 
    // ══════════════════════════════════════════
    // ── STUDENT SUMMONS METHODS ──
    // Student can receive summons via:
    // 1. matric_no (MISCONDUCT type)
    // 2. plate_number of their vehicle (VEHICLE type)
    // ══════════════════════════════════════════
 
    // ── Count total summons for student ──
    public int countTotalByStudent(String matricNo, String studentId)
            throws ClassNotFoundException {
 
        String query = "SELECT COUNT(*) FROM summons s " +
                       "WHERE s.matric_no = ? " +
                       "OR s.plate_number IN (" +
                       "  SELECT plate_number FROM vehicle WHERE student_id = ?" +
                       ")";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, matricNo);
            ps.setString(2, studentId);
 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
 
    // ── Count summons by status for student ──
    public int countByStatusForStudent(String matricNo, String studentId, String status)
            throws ClassNotFoundException {
 
        String query = "SELECT COUNT(*) FROM summons s " +
                       "WHERE s.status = ? " +
                       "AND (" +
                       "  s.matric_no = ? " +
                       "  OR s.plate_number IN (" +
                       "    SELECT plate_number FROM vehicle WHERE student_id = ?" +
                       "  )" +
                       ")";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, status);
            ps.setString(2, matricNo);
            ps.setString(3, studentId);
 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
 
    // ── Get total outstanding balance for student ──
    public double getTotalOutstandingByStudent(String matricNo, String studentId)
            throws ClassNotFoundException {
 
        String query = "SELECT COALESCE(SUM(s.amount), 0) FROM summons s " +
                       "WHERE s.status = 'UNPAID' " +
                       "AND (" +
                       "  s.matric_no = ? " +
                       "  OR s.plate_number IN (" +
                       "    SELECT plate_number FROM vehicle WHERE student_id = ?" +
                       "  )" +
                       ")";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, matricNo);
            ps.setString(2, studentId);
 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble(1);
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
 
    // ── Get all summons for student ──
    public List<Summons> getAllByStudent(String matricNo, String studentId)
            throws ClassNotFoundException {
 
        List<Summons> list = new ArrayList<>();
        String query = "SELECT s.*, o.offense_name " +
                       "FROM summons s " +
                       "JOIN student_offense_type o ON s.offense_id = o.offense_id " +
                       "WHERE s.matric_no = ? " +
                       "OR s.plate_number IN (" +
                       "  SELECT plate_number FROM vehicle WHERE student_id = ?" +
                       ") " +
                       "ORDER BY s.created_at DESC";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, matricNo);
            ps.setString(2, studentId);
 
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Summons s = mapResultSet(rs);
                    list.add(s);
                }
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
 
    // ── Get recent summons for student (limited) ──
    public List<Summons> getRecentByStudent(String matricNo, String studentId, int limit)
            throws ClassNotFoundException {
 
        List<Summons> list = new ArrayList<>();
        String query = "SELECT s.*, o.offense_name " +
                       "FROM summons s " +
                       "JOIN student_offense_type o ON s.offense_id = o.offense_id " +
                       "WHERE s.matric_no = ? " +
                       "OR s.plate_number IN (" +
                       "  SELECT plate_number FROM vehicle WHERE student_id = ?" +
                       ") " +
                       "ORDER BY s.created_at DESC LIMIT ?";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, matricNo);
            ps.setString(2, studentId);
            ps.setInt(3, limit);
 
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Summons s = mapResultSet(rs);
                    list.add(s);
                }
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
 
    // ── Get Recent Summons by Patrol Staff (limited) ──
    public List<Summons> getRecentByPatrol(String patrolStaffId, int limit)
            throws ClassNotFoundException {
 
        List<Summons> list = new ArrayList<>();
        String query = "SELECT s.*, o.offense_name " +
                       "FROM summons s " +
                       "JOIN student_offense_type o ON s.offense_id = o.offense_id " +
                       "WHERE s.patrol_staff_id = ? " +
                       "ORDER BY s.created_at DESC LIMIT ?";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, patrolStaffId);
            ps.setInt(2, limit);
 
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Summons s = mapResultSet(rs);
                    list.add(s);
                }
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
 
    // ── Private helper: map ResultSet to Summons object ──
    private Summons mapResultSet(ResultSet rs) throws SQLException {
        Summons s = new Summons();
        s.setSummonsId(rs.getString("summons_id"));
        s.setSummonsDate(rs.getString("summons_date"));
        s.setSummonsType(rs.getString("summons_type"));
        s.setOffenseId(rs.getString("offense_id"));
        s.setDescription(rs.getString("description"));
        s.setAmount(rs.getDouble("amount"));
        s.setStatus(rs.getString("status"));
        s.setLocation(rs.getString("location"));
        s.setPlateNumber(rs.getString("plate_number"));
        s.setMatricNo(rs.getString("matric_no"));
        s.setPatrolStaffId(rs.getString("patrol_staff_id"));
        s.setCreatedAt(rs.getString("created_at"));
        s.setUpdatedAt(rs.getString("updated_at"));

        // evidence_path (may not exist in every query's SELECT list)
        try { s.setEvidencePath(rs.getString("evidence_path")); }
        catch (SQLException ignored) {}
 
        // offense_name from JOIN (may not always be present)
        try { s.setOffenseName(rs.getString("offense_name")); } 
        catch (SQLException ignored) {}
 
        return s;
    }
}