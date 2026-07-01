/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;
 
import model.PatrolStaff;
import util.DBConnection;
 
import java.sql.*;
 
public class PatrolStaffDAO {
 
    // ── Login ──
    public PatrolStaff login(String email, String password) 
            throws ClassNotFoundException, SQLException {
 
        String query = "SELECT * FROM patrolstaff " +
                       "WHERE email = ? AND password = ?";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, email);
            ps.setString(2, password);
 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PatrolStaff p = new PatrolStaff();
                    p.setPatrolStaffId(rs.getString("patrolStaffID"));
                    p.setPatrolName(rs.getString("patrolName"));
                    p.setEmail(rs.getString("email"));
                    p.setPhoneNumber(rs.getString("phoneNumber"));
                    p.setPassword(rs.getString("password"));
                    return p;
                }
            }
 
        } catch (SQLException e) {
            System.out.println("=== PatrolStaffDAO login ERROR ===");
            System.out.println("Email    : " + email);
            System.out.println("SQL Error: " + e.getMessage());
            System.out.println("==================================");
            e.printStackTrace();
            throw e;
        }
        return null;
    }
 
    // ── Get Patrol Staff By ID ──
    public PatrolStaff getById(String patrolStaffId) 
            throws ClassNotFoundException, SQLException {
 
        String query = "SELECT * FROM patrolstaff WHERE patrolStaffID = ?";
 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
 
            ps.setString(1, patrolStaffId);
 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PatrolStaff p = new PatrolStaff();
                    p.setPatrolStaffId(rs.getString("patrolStaffID"));
                    p.setPatrolName(rs.getString("patrolName"));
                    p.setEmail(rs.getString("email"));
                    p.setPhoneNumber(rs.getString("phoneNumber"));
                    p.setPassword(rs.getString("password"));
                    return p;
                }
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
            throw e;
        }
        return null;
    }
}
