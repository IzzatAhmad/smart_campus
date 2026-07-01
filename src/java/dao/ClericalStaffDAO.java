/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.ClericalStaff;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class ClericalStaffDAO {

    // LOGIN (plain password)
    public ClericalStaff login(String email, String password) throws Exception {
        String sql = "SELECT * FROM clerical_staff WHERE email=? AND password=? LIMIT 1";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                ClericalStaff c = new ClericalStaff();
                c.setClericalStaffId(rs.getString("clerical_staff_id"));
                c.setClericalName(rs.getString("clerical_name"));
                c.setEmail(rs.getString("email"));
                c.setPhoneNumber(rs.getString("phone_number"));
                c.setPassword(rs.getString("password"));
                return c;
            }
        }
    }
}

