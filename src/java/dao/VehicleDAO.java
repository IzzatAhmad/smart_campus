/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.Vehicle;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VehicleDAO {

    private String generateNextVehicleId(Connection con) throws SQLException {
        String sql = "SELECT vehicle_id FROM vehicle ORDER BY vehicle_id DESC LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                String last = rs.getString("vehicle_id"); // e.g. VEH0007
                int num = Integer.parseInt(last.substring(3)) + 1;
                return "VEH" + String.format("%04d", num);
            }
            return "VEH0001";
        }
    }

    // Student: Create vehicle registration (PENDING)
    public Vehicle create(Vehicle v) throws Exception {
        try (Connection con = DBConnection.getConnection()) {
            String newId = generateNextVehicleId(con);

            String sql = "INSERT INTO vehicle " +
                    "(vehicle_id, student_id, vehicle_type, plate_number, brand, color, engine_cc, grant_image_path, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PENDING')";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, newId);
                ps.setString(2, v.getStudentId());
                ps.setString(3, v.getVehicleType());
                ps.setString(4, v.getPlateNumber());
                ps.setString(5, v.getBrand());
                ps.setString(6, v.getColor());
                ps.setString(7, v.getEngineCC());
                ps.setString(8, v.getGrantImagePath());

                int rows = ps.executeUpdate();
                if (rows == 1) {
                    v.setVehicleId(newId);
                    v.setStatus("PENDING");
                    return v;
                }
                return null;
            }
        }
    }

    // Student: List own vehicles
    public List<Vehicle> listByStudent(String studentId) throws Exception {
        String sql = "SELECT * FROM vehicle WHERE student_id=? ORDER BY created_at DESC";
        List<Vehicle> list = new ArrayList<>();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Vehicle v = new Vehicle();
                    v.setVehicleId(rs.getString("vehicle_id"));
                    v.setStudentId(rs.getString("student_id"));
                    v.setVehicleType(rs.getString("vehicle_type"));
                    v.setPlateNumber(rs.getString("plate_number"));
                    v.setBrand(rs.getString("brand"));
                    v.setColor(rs.getString("color"));
                    v.setEngineCC(rs.getString("engine_cc"));
                    v.setGrantImagePath(rs.getString("grant_image_path"));
                    v.setStatus(rs.getString("status"));
                    v.setClerkComment(rs.getString("clerk_comment"));
                    list.add(v);
                }
            }
        }
        return list;
    }

    // Clerical: list pending requests — joined with student for name + matric
    public List<Vehicle> listPending() throws Exception {
        String sql =
            "SELECT v.*, " +
            "       COALESCE(s.student_name, 'N/A') AS student_name, " +
            "       COALESCE(s.matric_no,    'N/A') AS matric_no, " +
            "       COALESCE(s.faculty,      'N/A') AS faculty, " +
            "       COALESCE(s.phone_number, 'N/A') AS phone_number " +
            "FROM vehicle v " +
            "LEFT JOIN student s ON v.student_id = s.student_id " +
            "WHERE v.status = 'PENDING' " +
            "ORDER BY v.created_at ASC";
        List<Vehicle> list = new ArrayList<>();
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
 
            while (rs.next()) {
                Vehicle v = new Vehicle();
                v.setVehicleId(rs.getString("vehicle_id"));
                v.setStudentId(rs.getString("student_id"));
                v.setVehicleType(rs.getString("vehicle_type"));
                v.setPlateNumber(rs.getString("plate_number"));
                v.setBrand(rs.getString("brand"));
                v.setColor(rs.getString("color"));
                v.setEngineCC(rs.getString("engine_cc"));
                v.setGrantImagePath(rs.getString("grant_image_path"));
                v.setStatus(rs.getString("status"));
                v.setClerkComment(rs.getString("clerk_comment"));
                v.setStudentName(rs.getString("student_name"));
                v.setMatricNo(rs.getString("matric_no"));
                list.add(v);
            }
        }
        return list;
    }

    // Clerical: approve / reject
    public boolean decide(String vehicleId, String status, String comment) throws Exception {
        String sql = "UPDATE vehicle SET status=?, clerk_comment=? WHERE vehicle_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setString(2, comment);
            ps.setString(3, vehicleId);

            return ps.executeUpdate() == 1;
        }
    }
    
    public Vehicle findByIdAndStudent(String vehicleId, String studentId) throws Exception {
    String sql = "SELECT * FROM vehicle WHERE vehicle_id=? AND student_id=?";
    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setString(1, vehicleId);
        ps.setString(2, studentId);

        try (ResultSet rs = ps.executeQuery()) {
            if (!rs.next()) return null;

            Vehicle v = new Vehicle();
            v.setVehicleId(rs.getString("vehicle_id"));
            v.setStudentId(rs.getString("student_id"));
            v.setVehicleType(rs.getString("vehicle_type"));
            v.setPlateNumber(rs.getString("plate_number"));
            v.setBrand(rs.getString("brand"));
            v.setColor(rs.getString("color"));
            v.setEngineCC(rs.getString("engine_cc"));
            v.setGrantImagePath(rs.getString("grant_image_path"));
            v.setStatus(rs.getString("status"));
            v.setClerkComment(rs.getString("clerk_comment"));
            return v;
        }
    }
}

    public boolean updateByStudent(Vehicle v, String studentId) throws Exception {
        // Only allow update if still PENDING
        String sql = "UPDATE vehicle SET vehicle_type=?, plate_number=?, brand=?, color=?, engine_cc=?, grant_image_path=? " +
                     "WHERE vehicle_id=? AND student_id=? AND status='PENDING'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, v.getVehicleType());
            ps.setString(2, v.getPlateNumber());
            ps.setString(3, v.getBrand());
            ps.setString(4, v.getColor());
            ps.setString(5, v.getEngineCC());
            ps.setString(6, v.getGrantImagePath());
            ps.setString(7, v.getVehicleId());
            ps.setString(8, studentId);

            return ps.executeUpdate() == 1;
        }
    }

    public boolean deleteByStudent(String vehicleId, String studentId) throws Exception {
        // Only allow delete if vehicle has no summons (checked by servlet before calling this)
        String sql = "DELETE FROM vehicle WHERE vehicle_id=? AND student_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, vehicleId);
            ps.setString(2, studentId);
            return ps.executeUpdate() == 1;
        }
    }
    
    public boolean updateByStudentWithStatus(Vehicle v, String studentId, String status) throws Exception {
    String sql = "UPDATE vehicle " +
                 "SET vehicle_type=?, plate_number=?, brand=?, color=?, engine_cc=?, grant_image_path=?, status=? " +
                 "WHERE vehicle_id=? AND student_id=?";
    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setString(1, v.getVehicleType());
        ps.setString(2, v.getPlateNumber());
        ps.setString(3, v.getBrand());
        ps.setString(4, v.getColor());
        ps.setString(5, v.getEngineCC());
        ps.setString(6, v.getGrantImagePath());
        ps.setString(7, status);

        ps.setString(8, v.getVehicleId());
        ps.setString(9, studentId);

        return ps.executeUpdate() == 1;
    }

    }

    

    // ── Update color only (status preserved as-is) ──
    public boolean updateColorOnly(String vehicleId, String studentId, String color) throws Exception {
        String sql = "UPDATE vehicle SET color=? WHERE vehicle_id=? AND student_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, color);
            ps.setString(2, vehicleId);
            ps.setString(3, studentId);
            return ps.executeUpdate() == 1;
        }
    }

    // ── Check if vehicle has any summons (by plate_number) ──
    public boolean hasSummons(String vehicleId) throws Exception {
        String sql = "SELECT 1 FROM summons s " +
                     "JOIN vehicle v ON s.plate_number = v.plate_number " +
                     "WHERE v.vehicle_id = ? LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, vehicleId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

}