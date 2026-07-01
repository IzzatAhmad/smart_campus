/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.OffenseType;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OffenseTypeDAO {

    // ── Generate next offense ID ──
    // Format: OFF001, OFF002, OFF003...
    public String generateOffenseId() throws ClassNotFoundException {
        String id = "OFF001";
        String query = "SELECT offense_id FROM student_offense_type " +
                       "ORDER BY offense_id DESC LIMIT 1";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                String lastId = rs.getString("offense_id");
                int num = Integer.parseInt(lastId.replace("OFF", ""));
                num++;
                id = String.format("OFF%03d", num);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return id;
    }

    // ── Get All Offense Types ──
    public List<OffenseType> getAllOffenseTypes() throws ClassNotFoundException {
        List<OffenseType> list = new ArrayList<>();
        String query = "SELECT o.*, c.clerical_name " +
                       "FROM student_offense_type o " +
                       "JOIN clerical_staff c ON o.created_by = c.clerical_staff_id " +
                       "ORDER BY o.offense_category, o.offense_name";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                OffenseType o = new OffenseType();
                o.setOffenseId(rs.getString("offense_id"));
                o.setOffenseName(rs.getString("offense_name"));
                o.setOffenseCategory(rs.getString("offense_category"));
                o.setAmount(rs.getDouble("amount"));
                o.setDescription(rs.getString("description"));
                o.setStatus(rs.getString("status"));
                o.setCreatedBy(rs.getString("created_by"));       // ID for FK
                o.setCreatedByName(rs.getString("clerical_name")); // Name for display
                o.setCreatedAt(rs.getString("created_at"));
                o.setUpdatedAt(rs.getString("updated_at"));
                list.add(o);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ── Get Active Offense Types Only ──
    // Used by patrol staff when creating summons
    public List<OffenseType> getActiveOffenseTypes() throws ClassNotFoundException {
        List<OffenseType> list = new ArrayList<>();
        String query = "SELECT * FROM student_offense_type " +
                       "WHERE status = 'ACTIVE' " +
                       "ORDER BY offense_category, offense_name";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                OffenseType o = new OffenseType();
                o.setOffenseId(rs.getString("offense_id"));
                o.setOffenseName(rs.getString("offense_name"));
                o.setOffenseCategory(rs.getString("offense_category"));
                o.setAmount(rs.getDouble("amount"));
                o.setDescription(rs.getString("description"));
                o.setStatus(rs.getString("status"));
                list.add(o);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ── Get Offense Types By Category ──
    // Used by patrol staff dropdown (MISCONDUCT or VEHICLE)
    public List<OffenseType> getByCategory(String category) throws ClassNotFoundException {
        List<OffenseType> list = new ArrayList<>();
        String query = "SELECT * FROM student_offense_type " +
                       "WHERE offense_category = ? AND status = 'ACTIVE' " +
                       "ORDER BY offense_name";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, category);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OffenseType o = new OffenseType();
                    o.setOffenseId(rs.getString("offense_id"));
                    o.setOffenseName(rs.getString("offense_name"));
                    o.setOffenseCategory(rs.getString("offense_category"));
                    o.setAmount(rs.getDouble("amount"));
                    o.setDescription(rs.getString("description"));
                    o.setStatus(rs.getString("status"));
                    list.add(o);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ── Get Single Offense By ID ──
    public OffenseType getOffenseById(String offenseId) throws ClassNotFoundException {
        String query = "SELECT * FROM student_offense_type WHERE offense_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, offenseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    OffenseType o = new OffenseType();
                    o.setOffenseId(rs.getString("offense_id"));
                    o.setOffenseName(rs.getString("offense_name"));
                    o.setOffenseCategory(rs.getString("offense_category"));
                    o.setAmount(rs.getDouble("amount"));
                    o.setDescription(rs.getString("description"));
                    o.setStatus(rs.getString("status"));
                    o.setCreatedBy(rs.getString("created_by"));
                    o.setCreatedAt(rs.getString("created_at"));
                    return o;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ── Add New Offense Type ──
    public boolean addOffenseType(OffenseType o) throws ClassNotFoundException {
    String query = "INSERT INTO student_offense_type " +
                   "(offense_id, offense_name, offense_category, " +
                   "amount, description, status, created_by) " +
                   "VALUES (?, ?, ?, ?, ?, 'ACTIVE', ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, o.getOffenseId());
            ps.setString(2, o.getOffenseName());
            ps.setString(3, o.getOffenseCategory());
            ps.setDouble(4, o.getAmount());
            ps.setString(5, o.getDescription());
            ps.setString(6, o.getCreatedBy());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            // Print exact error
            System.out.println("=== DAO addOffenseType ERROR ===");
            System.out.println("offense_id   : " + o.getOffenseId());
            System.out.println("offense_name : " + o.getOffenseName());
            System.out.println("category     : " + o.getOffenseCategory());
            System.out.println("amount       : " + o.getAmount());
            System.out.println("description  : " + o.getDescription());
            System.out.println("created_by   : " + o.getCreatedBy());
            System.out.println("SQL Error    : " + e.getMessage());
            System.out.println("================================");
            e.printStackTrace();
            return false;
        }
    }

    // ── Edit Offense Type ──
    public boolean editOffenseType(OffenseType o) throws ClassNotFoundException {
        String query = "UPDATE student_offense_type " +
                       "SET offense_name = ?, offense_category = ?, " +
                       "amount = ?, description = ? " +
                       "WHERE offense_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, o.getOffenseName());
            ps.setString(2, o.getOffenseCategory());
            ps.setDouble(3, o.getAmount());
            ps.setString(4, o.getDescription());
            ps.setString(5, o.getOffenseId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── Toggle Status (Activate / Deactivate) ──
    public boolean toggleStatus(String offenseId, String newStatus) throws ClassNotFoundException {
        String query = "UPDATE student_offense_type " +
                       "SET status = ? " +
                       "WHERE offense_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, newStatus);
            ps.setString(2, offenseId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── Check if offense name already exists ──
    public boolean isOffenseNameExists(String offenseName, String excludeId) throws ClassNotFoundException {
        String query = "SELECT COUNT(*) FROM student_offense_type " +
                       "WHERE LOWER(offense_name) = LOWER(?) " +
                       "AND offense_id != ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, offenseName);
            ps.setString(2, excludeId != null ? excludeId : "");

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}