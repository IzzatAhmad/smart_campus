/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.Student;
import util.DBConnection;

import java.sql.*;

public class StudentDAO {

    private String generateNextStudentId(Connection con) throws SQLException {
        String sql = "SELECT student_id FROM student ORDER BY student_id DESC LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                String last = rs.getString("student_id"); // e.g. STU0007
                int num = Integer.parseInt(last.substring(3)) + 1;
                return "STU" + String.format("%04d", num);
            }
            return "STU0001";
        }
    }

    public boolean emailOrMatricExists(String email, String matricNo) throws Exception {
        String sql = "SELECT 1 FROM student WHERE email=? OR matric_no=? LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, matricNo);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // ✅ REGISTER (plain password) + faculty + uniqueness check
    public Student register(Student s) throws Exception {
        try (Connection con = DBConnection.getConnection()) {

            // IMPORTANT: prevent duplicate email/matric
            if (emailOrMatricExists(s.getEmail(), s.getMatricNo())) {
                return null;
            }

            String newId = generateNextStudentId(con);

            String sql = "INSERT INTO student (student_id, student_name, matric_no, email, phone_number, faculty, password) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?)";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, newId);
                ps.setString(2, s.getStudentName());
                ps.setString(3, s.getMatricNo());
                ps.setString(4, s.getEmail());
                ps.setString(5, s.getPhoneNumber());
                ps.setString(6, s.getFaculty());   // ✅ NEW
                ps.setString(7, s.getPassword());

                int rows = ps.executeUpdate();
                if (rows == 1) {
                    s.setStudentId(newId);
                    return s;
                }
                return null;
            }
        }
    }

    // ✅ LOGIN (plain password) + faculty
    public Student login(String email, String password) throws Exception {
        String sql = "SELECT * FROM student WHERE email=? AND password=? LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                Student s = new Student();
                s.setStudentId(rs.getString("student_id"));
                s.setStudentName(rs.getString("student_name"));
                s.setMatricNo(rs.getString("matric_no"));
                s.setEmail(rs.getString("email"));
                s.setPhoneNumber(rs.getString("phone_number"));
                s.setFaculty(rs.getString("faculty")); // ✅ NEW
                s.setPassword(rs.getString("password"));
                return s;
            }
        }
    }

    // ✅ READ PROFILE + faculty
    public Student getById(String studentId) throws Exception {
        String sql = "SELECT * FROM student WHERE student_id=? LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                Student s = new Student();
                s.setStudentId(rs.getString("student_id"));
                s.setStudentName(rs.getString("student_name"));
                s.setMatricNo(rs.getString("matric_no"));
                s.setEmail(rs.getString("email"));
                s.setPhoneNumber(rs.getString("phone_number"));
                s.setFaculty(rs.getString("faculty")); // ✅ NEW
                s.setPassword(rs.getString("password"));
                return s;
            }
        }
    }
    
    // ── Get student by Matric No (used by ClericalPaymentServlet for email sending) ──
    public Student getStudentByMatricNo(String matricNo) throws Exception {
        String sql = "SELECT * FROM student WHERE matric_no = ? LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, matricNo);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                Student s = new Student();
                s.setStudentId(rs.getString("student_id"));
                s.setStudentName(rs.getString("student_name"));
                s.setMatricNo(rs.getString("matric_no"));
                s.setEmail(rs.getString("email"));
                s.setPhoneNumber(rs.getString("phone_number"));
                s.setFaculty(rs.getString("faculty"));
                s.setPassword(rs.getString("password"));
                return s;
            }
        }
    }

    // ✅ UPDATE PROFILE (name + phone + faculty)
    public boolean updateProfile(String studentId, String name, String phone, String faculty) throws Exception {
        String sql = "UPDATE student SET student_name=?, phone_number=?, faculty=? WHERE student_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, name);
            ps.setString(2, phone);
            ps.setString(3, faculty);     // ✅ NEW
            ps.setString(4, studentId);

            return ps.executeUpdate() == 1;
        }
    }
}

