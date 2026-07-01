/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    
    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        // Load the MySQL JDBC driver
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        // Fetch variables injected by Docker, falling back to local defaults if not set
        String host = System.getenv().getOrDefault("DB_HOST", "localhost");
        String port = System.getenv().getOrDefault("DB_PORT", "3306");
        String name = System.getenv().getOrDefault("DB_NAME", "smart_campus");
        String user = System.getenv().getOrDefault("DB_USER", "root");
        String pass = System.getenv().getOrDefault("DB_PASSWORD", "admin");

        String url = "jdbc:mysql://" + host + ":" + port + "/" + name + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
        
        // Return a connection to the database
        return DriverManager.getConnection(url, user, pass);
    }
    
    public static void main(String[] args) {
        // Test the database connection
        try (Connection conn = getConnection()) {
            // Check if the connection is successful
            if (conn != null && !conn.isClosed()) {
                System.out.println("✅ Connection successful!");
            } else {
                System.out.println("❌ Connection failed.");
            }
        } catch (SQLException e) {
            System.err.println("❌ SQL Error while connecting to database: " + e.getMessage());
        } catch (ClassNotFoundException e) {
            System.err.println("❌ JDBC Driver not found: " + e.getMessage());
        } catch (Exception e) {
            System.err.println("❌ Unexpected error: " + e.getMessage());
        }
    }
}

