/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.AppealDAO;
import dao.ClericalMonitorDAO;
import dao.PaymentDAO;
import dao.SummonsDAO;
import dao.VehicleDAO;
import model.Appeal;
import model.ClericalStaff;
import model.Summons;
import model.Vehicle;
import util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/clerical/dashboard")
public class ClericalDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        ClericalStaff c = (ClericalStaff) req.getSession().getAttribute("clerical");
        if (c == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            // ── 1. Total registered students ──
            int totalStudents = 0;
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM student");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalStudents = rs.getInt(1);
            }

            // ── 2. Total patrol staff ──
            int totalPatrol = 0;
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM patrolstaff");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalPatrol = rs.getInt(1);
            }

            // ── 3. Total summons + unpaid count via ReportDAO summary ──
            int totalSummons = 0;
            int unpaidSummons = 0;
            double totalOutstanding = 0.0;
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(
                     "SELECT COUNT(*) AS total, " +
                     "SUM(CASE WHEN status='UNPAID' THEN 1 ELSE 0 END) AS unpaid, " +
                     "COALESCE(SUM(CASE WHEN status='UNPAID' THEN amount ELSE 0 END),0) AS outstanding " +
                     "FROM summons");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalSummons    = rs.getInt("total");
                    unpaidSummons   = rs.getInt("unpaid");
                    totalOutstanding = rs.getDouble("outstanding");
                }
            }

            // ── 4. Pending office payments (PENDING_OFFICE) ──
            int pendingPayments = 0;
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(
                     "SELECT COUNT(*) FROM payment WHERE status = 'PENDING_OFFICE'");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) pendingPayments = rs.getInt(1);
            }

            // ── 5. Pending vehicle approvals ──
            int pendingVehicles = 0;
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(
                     "SELECT COUNT(*) FROM vehicle WHERE status = 'PENDING'");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) pendingVehicles = rs.getInt(1);
            }

            // ── 6. Pending appeals ──
            int pendingAppeals = new AppealDAO().countPendingAppeals();

            // ── 7. Recent 5 pending appeals for the action table ──
            List<Appeal> recentAppeals = new AppealDAO().getAllAppeals();
            // Filter to PENDING only, max 5
            java.util.List<Appeal> pendingAppealList = new java.util.ArrayList<>();
            for (Appeal a : recentAppeals) {
                if ("PENDING".equals(a.getStatus())) {
                    pendingAppealList.add(a);
                    if (pendingAppealList.size() >= 5) break;
                }
            }

            // ── 8. Recent 5 office payments needing verification ──
            List<Map<String, String>> officePayments = new PaymentDAO().getAllOfficePayments();
            // Filter to PENDING_OFFICE only, max 5
            java.util.List<Map<String, String>> pendingOfficeList = new java.util.ArrayList<>();
            for (Map<String, String> pm : officePayments) {
                if ("PENDING_OFFICE".equals(pm.get("payStatus"))) {
                    pendingOfficeList.add(pm);
                    if (pendingOfficeList.size() >= 5) break;
                }
            }

            // ── Set all attributes ──
            req.setAttribute("totalStudents",    totalStudents);
            req.setAttribute("totalPatrol",      totalPatrol);
            req.setAttribute("totalSummons",     totalSummons);
            req.setAttribute("unpaidSummons",    unpaidSummons);
            req.setAttribute("totalOutstanding", totalOutstanding);
            req.setAttribute("pendingPayments",  pendingPayments);
            req.setAttribute("pendingVehicles",  pendingVehicles);
            req.setAttribute("pendingAppeals",   pendingAppeals);
            req.setAttribute("pendingAppealList",   pendingAppealList);
            req.setAttribute("pendingOfficeList",   pendingOfficeList);

        } catch (Exception ex) {
            Logger.getLogger(ClericalDashboardServlet.class.getName())
                  .log(Level.SEVERE, null, ex);
            // Safe defaults
            req.setAttribute("totalStudents",    0);
            req.setAttribute("totalPatrol",      0);
            req.setAttribute("totalSummons",     0);
            req.setAttribute("unpaidSummons",    0);
            req.setAttribute("totalOutstanding", 0.0);
            req.setAttribute("pendingPayments",  0);
            req.setAttribute("pendingVehicles",  0);
            req.setAttribute("pendingAppeals",   0);
            req.setAttribute("pendingAppealList",   new java.util.ArrayList<>());
            req.setAttribute("pendingOfficeList",   new java.util.ArrayList<>());
        }

        req.getRequestDispatcher("/clerical/dashboard.jsp").forward(req, resp);
    }
}

