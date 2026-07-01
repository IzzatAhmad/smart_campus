/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/test-db-connection")  // URL pattern to test the DB connection
public class TestDatabaseConnectionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            // Connect to the database
            con = DBConnection.getConnection();
            stmt = con.createStatement();
            String sql = "SELECT student_id, student_name FROM student LIMIT 1";  // Fetch one record from the 'student' table
            rs = stmt.executeQuery(sql);

            if (rs.next()) {
                String studentId = rs.getString("student_id");
                String studentName = rs.getString("student_name");
                resp.getWriter().println("Database Connection Success!");
                resp.getWriter().println("First student: " + studentId + " - " + studentName);
            } else {
                resp.getWriter().println("No records found in the database.");
            }

        } catch (SQLException | ClassNotFoundException e) {
            // If there's an error, show it in the browser
            resp.getWriter().println("Error connecting to database: " + e.getMessage());
        } finally {
            try {
                // Close all resources
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                resp.getWriter().println("Error closing resources: " + e.getMessage());
            }
        }
    }
}
